//
//  A5ProcessMonitor.m
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import "A5ProcessMonitor.h"
#import "A5Constants.h"
#import <sys/sysctl.h>
#import <signal.h>

@interface A5ProcessMonitor ()

@property (assign, nonatomic, readwrite) BOOL isMonitoring;
@property (strong, nonatomic) NSMutableArray<NSString *> *processesToKill;
@property (strong, nonatomic) NSMutableArray<NSString *> *processPatterns;
@property (strong, nonatomic) dispatch_queue_t monitoringQueue;

@end

@implementation A5ProcessMonitor

- (instancetype)init {
    self = [super init];
    if (self) {
        _isMonitoring = NO;
        _monitoringQueue = dispatch_queue_create("com.a5.processmonitor", DISPATCH_QUEUE_SERIAL);

        // Initialize process kill list (from ProcessMonitor.cs lines 26-34)
        _processesToKill = [[NSMutableArray alloc] initWithArray:@[
            // Debuggers
            @"lldb", @"gdb", @"ida", @"ida64", @"idaq", @"idaq64",
            @"ghidra", @"ghidrarun", @"radare2", @"r2",
            @"x64dbg", @"x32dbg", @"ollydbg", @"hopper",
            @"immunity", @"scylla",

            // Proxies
            @"charles", @"burp", @"burpsuite", @"fiddler",
            @"mitmproxy", @"mitmdump", @"proxifier",
            @"proxyman",

            // Network analysis
            @"wireshark", @"tshark", @"tcpdump", @"tcpflow",
            @"ngrep", @"ettercap", @"netmon",

            // Reverse engineering
            @"dnspy", @"ilspy", @"dotpeek", @"justdecompile",
            @"reflector", @"jadx", @"apktool",

            // Process monitors
            @"procmon", @"processhacker",

            // Frida & dynamic analysis
            @"frida", @"frida-server",

            // Network tools
            @"nmap", @"ncat", @"netcat", @"scapy",

            // Mobile debugging
            @"adb", @"jdb"
        ]];

        // Pattern matching (from ProcessMonitor.cs line 35)
        _processPatterns = [[NSMutableArray alloc] initWithArray:@[
            @"debug",
            @"proxy",
            @"sniff",
            @"analyzer",
            @"monitor",
            @"inspector"
        ]];
    }
    return self;
}

- (void)dealloc {
    [self stopMonitoring];
}

#pragma mark - Public Methods

- (void)startMonitoring {
    if (self.isMonitoring) {
        return;
    }

    self.isMonitoring = YES;

    [self notifyDelegate:@"Bypass Process is Ready"];
    [self notifyDelegate:@"Background process protection activated"];

    // Start monitoring loop on background queue
    dispatch_async(self.monitoringQueue, ^{
        [self monitoringLoop];
    });
}

- (void)stopMonitoring {
    if (!self.isMonitoring) {
        return;
    }

    self.isMonitoring = NO;
    [self notifyDelegate:@"Protection disabled"];
}

- (BOOL)killProcessByName:(NSString *)processName {
    if (!processName || processName.length == 0) {
        return NO;
    }

    NSArray *processes = [self getAllProcesses];
    BOOL killedAny = NO;

    for (NSDictionary *processInfo in processes) {
        NSString *name = processInfo[@"name"];
        if ([name.lowercaseString isEqualToString:processName.lowercaseString]) {
            pid_t pid = [processInfo[@"pid"] intValue];

            if ([self killProcess:pid processName:name]) {
                killedAny = YES;
            }
        }
    }

    return killedAny;
}

- (BOOL)isProcessRunning:(NSString *)processName {
    if (!processName || processName.length == 0) {
        return NO;
    }

    NSArray *processes = [self getAllProcesses];

    for (NSDictionary *processInfo in processes) {
        NSString *name = processInfo[@"name"];
        if ([name.lowercaseString isEqualToString:processName.lowercaseString]) {
            return YES;
        }
    }

    return NO;
}

- (NSArray<NSString *> *)getRunningSuspiciousProcesses {
    NSMutableArray *suspicious = [NSMutableArray array];
    NSArray *processes = [self getAllProcesses];

    for (NSDictionary *processInfo in processes) {
        NSString *name = processInfo[@"name"];
        pid_t pid = [processInfo[@"pid"] intValue];

        if ([self shouldKillProcess:name]) {
            [suspicious addObject:[NSString stringWithFormat:@"%@ (PID: %d)", name, pid]];
        }
    }

    return [suspicious copy];
}

#pragma mark - Private Methods

- (void)monitoringLoop {
    while (self.isMonitoring) {
        @autoreleasepool {
            [self checkAndKillProcesses];

            // Sleep for 2 seconds (from ProcessMonitor.cs line 78)
            [NSThread sleepForTimeInterval:[A5Constants processMonitorInterval]];
        }
    }
}

- (void)checkAndKillProcesses {
    NSArray *processes = [self getAllProcesses];

    for (NSDictionary *processInfo in processes) {
        if (!self.isMonitoring) {
            break;
        }

        NSString *processName = processInfo[@"name"];
        pid_t pid = [processInfo[@"pid"] intValue];

        if ([self shouldKillProcess:processName]) {
            [self killProcess:pid processName:processName];
        }
    }
}

- (BOOL)shouldKillProcess:(NSString *)processName {
    if (!processName || processName.length == 0) {
        return NO;
    }

    NSString *lowercaseName = processName.lowercaseString;

    // Check exact matches (from ProcessMonitor.cs line 104)
    for (NSString *targetProcess in self.processesToKill) {
        if ([lowercaseName isEqualToString:targetProcess.lowercaseString]) {
            return YES;
        }
    }

    // Check pattern matches (from ProcessMonitor.cs lines 107-111)
    for (NSString *pattern in self.processPatterns) {
        if ([lowercaseName containsString:pattern.lowercaseString]) {
            return YES;
        }
    }

    // Check suspicious patterns (from ProcessMonitor.cs IsSuspiciousProcess)
    if ([self isSuspiciousProcess:lowercaseName]) {
        return YES;
    }

    return NO;
}

- (BOOL)isSuspiciousProcess:(NSString *)processName {
    // Debuggers (from ProcessMonitor.cs line 133)
    NSArray *debuggers = @[@"ollydbg", @"x64dbg", @"x32dbg", @"windbg", @"ida", @"immunity", @"lldb", @"gdb"];
    for (NSString *debugger in debuggers) {
        if ([processName containsString:debugger]) {
            return YES;
        }
    }

    // Proxy tools (from ProcessMonitor.cs line 137)
    NSArray *proxyTools = @[@"proxyman", @"zap", @"mitm", @"packet", @"traffic"];
    for (NSString *proxyTool in proxyTools) {
        if ([processName containsString:proxyTool]) {
            return YES;
        }
    }

    // TCP viewers (from ProcessMonitor.cs line 141)
    if ([processName containsString:@"tcp"] && [processName containsString:@"view"]) {
        return YES;
    }

    // Hook tools (from ProcessMonitor.cs line 145)
    if ([processName containsString:@"hook"]) {
        return YES;
    }

    return NO;
}

- (BOOL)killProcess:(pid_t)pid processName:(NSString *)processName {
    int result = kill(pid, SIGKILL);

    if (result == 0) {
        // Successfully sent kill signal
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(processKilled:pid:)]) {
                [self.delegate processKilled:processName pid:pid];
            }
        });

        [self notifyDelegate:[NSString stringWithFormat:@"BLOCKED: %@ (PID: %d)", processName, pid]];
        return YES;
    } else {
        [self notifyDelegate:[NSString stringWithFormat:@"WARNING: Could not terminate: %@ (PID: %d)", processName, pid]];
        return NO;
    }
}

- (NSArray *)getAllProcesses {
    NSMutableArray *processes = [NSMutableArray array];

    // Get process count
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t size;

    if (sysctl(mib, 4, NULL, &size, NULL, 0) < 0) {
        NSLog(@"Error getting process count");
        return processes;
    }

    // Allocate buffer for process info
    struct kinfo_proc *processList = malloc(size);
    if (!processList) {
        NSLog(@"Error allocating memory for process list");
        return processes;
    }

    // Get process list
    if (sysctl(mib, 4, processList, &size, NULL, 0) < 0) {
        NSLog(@"Error getting process list");
        free(processList);
        return processes;
    }

    int processCount = (int)(size / sizeof(struct kinfo_proc));

    // Extract process info
    for (int i = 0; i < processCount; i++) {
        struct kinfo_proc proc = processList[i];
        pid_t pid = proc.kp_proc.p_pid;
        NSString *processName = [NSString stringWithUTF8String:proc.kp_proc.p_comm];

        if (processName && processName.length > 0 && pid > 0) {
            [processes addObject:@{
                @"pid": @(pid),
                @"name": processName
            }];
        }
    }

    free(processList);
    return processes;
}

- (void)notifyDelegate:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(processMonitorLogMessage:)]) {
            [self.delegate processMonitorLogMessage:message];
        }
    });
}

@end
