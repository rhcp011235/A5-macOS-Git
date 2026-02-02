//
//  A5ActivationService.m
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import "A5ActivationService.h"
#import "A5CommandExecutor.h"
#import "A5Constants.h"
#import "A5BackendServer.h"
#import "A5AFCClient.h"
#import <sqlite3.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface A5ActivationService ()

@property (atomic) BOOL isCancelled;
@property (strong, nonatomic) dispatch_queue_t activationQueue;
@property (strong, nonatomic, nullable) A5BackendServer *backendServer;
@property (strong, nonatomic, nullable) NSTask *iproxyTask;
@property (strong, nonatomic, nullable) NSFileHandle *logFileHandle;
@property (strong, nonatomic, nullable) NSString *logFilePath;

@end

@implementation A5ActivationService

- (instancetype)init {
    self = [super init];
    if (self) {
        _isCancelled = NO;
        _activationQueue = dispatch_queue_create("com.a5.activation", DISPATCH_QUEUE_SERIAL);
        [self setupLogFile];
    }
    return self;
}

#pragma mark - Public Methods

- (void)activateDevice:(NSString *)udid {
    if (!udid || udid.length == 0) {
        [self notifyCompletion:NO message:@"No device UDID provided"];
        return;
    }

    self.isCancelled = NO;

    dispatch_async(self.activationQueue, ^{
        [self performActivationWorkflow:udid];
    });
}

- (void)cancelActivation {
    self.isCancelled = YES;
    [self notifyLog:@"Activation cancelled by user"];
    [self stopPHPServer];
}

#pragma mark - Private Methods - Activation Workflow

- (void)performActivationWorkflow:(NSString *)udid {
    [self notifyLog:[NSString stringWithFormat:@"=== Starting activation for device: %@", udid]];

    // Step 0: Start local PHP server for backend
    if (![self startPHPServerForDevice:udid]) {
        [self notifyCompletion:NO message:@"Failed to start backend server"];
        return;
    }
    [self notifyLog:@"✓ Backend server started successfully"];

    // Step 1: Transfer payload (20%)
    [self notifyLog:@"=== STEP 1: Transferring payload via AFC"];
    if (![self transferPayload:udid]) {
        [self notifyLog:@"✗ Payload transfer failed"];
        [self stopPHPServer];
        return;
    }
    [self notifyLog:@"✓ Step 1 complete: Payload transferred"];

    if (self.isCancelled) return;

    // Step 2: First device restart (60%)
    [self notifyLog:@"=== STEP 2: First device restart"];
    if (![self performFirstRestart]) {
        [self notifyLog:@"✗ First restart failed"];
        return;
    }
    [self notifyLog:@"✓ Step 2 complete: First restart initiated"];

    if (self.isCancelled) return;

    // Step 3: Wait 90 seconds
    [self notifyLog:@"=== STEP 3: Waiting 90 seconds for reboot"];
    [self waitForRestart:90 restartNumber:1];
    [self notifyLog:@"✓ Step 3 complete: Wait finished"];

    if (self.isCancelled) return;

    // Step 4: Second device restart (80%)
    [self notifyLog:@"=== STEP 4: Second device restart"];
    if (![self performSecondRestart]) {
        [self notifyLog:@"✗ Second restart failed"];
        return;
    }
    [self notifyLog:@"✓ Step 4 complete: Second restart initiated"];

    if (self.isCancelled) return;

    // Step 5: Wait 90 seconds
    [self notifyLog:@"=== STEP 5: Waiting 90 seconds for reboot"];
    [self waitForRestart:90 restartNumber:2];
    [self notifyLog:@"✓ Step 5 complete: Wait finished"];

    if (self.isCancelled) return;

    // Step 6: Verify activation (100%)
    [self notifyLog:@"=== STEP 6: Verifying activation via MobileGestalt"];
    [self verifyActivation];
}

// Step 1: Transfer activation payload to device
- (NSString *)getLocalIPAddress {
    // Get Mac's IP address on WiFi/Ethernet network
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;

    // Get list of all interfaces on local machine
    if (getifaddrs(&interfaces) == 0) {
        temp_addr = interfaces;

        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                NSString *interfaceName = [NSString stringWithUTF8String:temp_addr->ifa_name];

                // Check for WiFi (en0) or Ethernet (en1) or bridge100 (USB network)
                if([interfaceName isEqualToString:@"en0"] ||  // WiFi
                   [interfaceName isEqualToString:@"en1"] ||  // Ethernet
                   [interfaceName hasPrefix:@"bridge"]) {     // USB network bridge

                    char ipAddress[INET_ADDRSTRLEN];
                    inet_ntop(AF_INET, &((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr, ipAddress, INET_ADDRSTRLEN);
                    address = [NSString stringWithUTF8String:ipAddress];

                    if (![address isEqualToString:@"127.0.0.1"]) {
                        break; // Found valid IP
                    }
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }

    freeifaddrs(interfaces);
    return address;
}

- (NSString *)preparePayloadWithBackendURL:(NSString *)originalPath {
    // Create temporary copy of payload with modified backend URL
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"A5_payload_modified.db"];

    // Copy original to temp
    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil]; // Remove if exists
    NSError *copyError = nil;
    if (![[NSFileManager defaultManager] copyItemAtPath:originalPath toPath:tempPath error:&copyError]) {
        [self notifyLog:[NSString stringWithFormat:@"✗ Failed to create temp payload: %@", copyError.localizedDescription]];
        return originalPath; // Fall back to original
    }

    // Determine backend URL based on selection
    NSString *backendURL;
    NSString *backendName;

    switch (self.backendServerType) {
        case 0: // nothingtool.com
            backendURL = @"https://nothingtool.com/invoice.php";
            backendName = @"nothingtool.com";
            break;

        case 1: // mrcellphoneunlocker.com
            backendURL = @"http://mrcellphoneunlocker.com/A5/invoice.php";
            backendName = @"mrcellphoneunlocker.com";
            break;

        case 2: { // Local
            // Get Mac's WiFi IP address for local network access
            // This works when both Mac and device are on same WiFi network
            NSString *localIP = [self getLocalIPAddress];

            if (localIP && ![localIP isEqualToString:@"127.0.0.1"]) {
                backendURL = [NSString stringWithFormat:@"http://%@:8080/server.php", localIP];
                backendName = [NSString stringWithFormat:@"Local - %@", localIP];
            } else {
                // Fallback to Mac.local
                backendURL = @"http://Mac.local:8080/server.php";
                backendName = @"Local - Mac.local";
            }
            break;
        }

        default:
            backendURL = @"https://nothingtool.com/invoice.php";
            backendName = @"nothingtool.com (default)";
            break;
    }

    // Update URL in SQLite database
    char *errMsg;
    sqlite3 *db;
    if (sqlite3_open([tempPath UTF8String], &db) == SQLITE_OK) {
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE asset SET url = '%@' WHERE url LIKE '%%server.php%%' OR url LIKE '%%invoice.php%%';", backendURL];
        sqlite3_exec(db, [updateSQL UTF8String], NULL, NULL, &errMsg);
        sqlite3_close(db);

        [self notifyLog:[NSString stringWithFormat:@"✓ Payload configured for %@ backend", backendName]];
        [self notifyLog:[NSString stringWithFormat:@"  Backend URL: %@", backendURL]];
    } else {
        [self notifyLog:@"⚠️ Could not modify payload URL, using default"];
    }

    return tempPath;
}

- (BOOL)transferPayload:(NSString *)udid {
    [self notifyProgress:20 message:@"Preparing your device info, please wait..."];

    // Get payload path from bundle
    NSString *originalPayloadPath = [[NSBundle mainBundle] pathForResource:[A5Constants activationPayloadName]
                                                             ofType:nil
                                                        inDirectory:[A5Constants payloadsDirectoryName]];

    if (!originalPayloadPath || ![[NSFileManager defaultManager] fileExistsAtPath:originalPayloadPath]) {
        [self notifyCompletion:NO message:@"Activation payload not found in bundle"];
        return NO;
    }

    // Prepare payload with correct backend URL
    NSString *payloadPath = [self preparePayloadWithBackendURL:originalPayloadPath];

    // Use native AFC protocol - matches Python implementation exactly
    // Path is relative to AFC root (Media directory)
    NSString *remotePath = @"Downloads/downloads.28.sqlitedb";
    NSError *afcError = nil;

    [self notifyLog:[NSString stringWithFormat:@"Transferring payload via AFC to %@", remotePath]];

    BOOL success = [A5AFCClient transferFile:payloadPath
                                  toDevice:udid
                                remotePath:remotePath
                                     error:&afcError];

    if (success) {
        [self notifyLog:[NSString stringWithFormat:@"✓ Payload transferred successfully to: %@", remotePath]];
        [self notifyLog:[NSString stringWithFormat:@"✓ Payload size: %llu bytes", [[[NSFileManager defaultManager] attributesOfItemAtPath:payloadPath error:nil] fileSize]]];
        return YES;
    } else {
        [self notifyLog:[NSString stringWithFormat:@"✗ AFC transfer failed: %@", afcError.localizedDescription]];
        // Try fallback path
        NSString *fallbackPath = @"PublicStaging/downloads.28.sqlitedb";
        [self notifyLog:[NSString stringWithFormat:@"Trying fallback path: %@", fallbackPath]];

        success = [A5AFCClient transferFile:payloadPath
                                  toDevice:udid
                                remotePath:fallbackPath
                                     error:&afcError];

        if (success) {
            [self notifyLog:@"Payload transferred successfully via native AFC (fallback path)"];
            return YES;
        }
    }

    // Both paths failed
    NSString *errorMsg = afcError ? afcError.localizedDescription : @"Unknown AFC error";
    [self notifyCompletion:NO message:[NSString stringWithFormat:@"AFC transfer failed: %@", errorMsg]];
    return NO;
}

// Step 2: First device restart
- (BOOL)performFirstRestart {
    [self notifyProgress:60 message:@"[1] Restarting your device, please wait..."];
    [self notifyLog:@"Executing: idevicediagnostics restart"];

    __block BOOL success = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [A5CommandExecutor executeCommand:[A5Constants idevicediagnosticsTool]
                            arguments:@[@"restart"]
                           completion:^(NSString *output, NSString *error, NSError *executionError) {
        [self notifyLog:[NSString stringWithFormat:@"Restart command output: %@", output ?: @"(empty)"]];
        if (error && error.length > 0) {
            [self notifyLog:[NSString stringWithFormat:@"Restart command stderr: %@", error]];
        }

        if (!executionError && [output containsString:@"Restarting device"]) {
            success = YES;
            [self notifyLog:@"✓ First restart command accepted by device"];
        } else {
            [self notifyLog:[NSString stringWithFormat:@"✗ Restart failed - error: %@", executionError.localizedDescription ?: @"output missing 'Restarting device'"]];
            [self notifyCompletion:NO message:@"Trust Device or check connection USB Cable!"];
        }

        dispatch_semaphore_signal(semaphore);
    }];

    long result = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    if (result != 0) {
        [self notifyLog:@"✗ Restart command timed out after 30 seconds"];
        success = NO;
    }

    if (!success) {
        [self stopPHPServer];
    }
    return success;
}

// Step 4: Second device restart
- (BOOL)performSecondRestart {
    [self notifyProgress:80 message:@"[2] Restarting your device, please wait..."];
    [self notifyLog:@"Executing: idevicediagnostics restart"];

    __block BOOL success = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [A5CommandExecutor executeCommand:[A5Constants idevicediagnosticsTool]
                            arguments:@[@"restart"]
                           completion:^(NSString *output, NSString *error, NSError *executionError) {
        [self notifyLog:[NSString stringWithFormat:@"Restart command output: %@", output ?: @"(empty)"]];
        if (error && error.length > 0) {
            [self notifyLog:[NSString stringWithFormat:@"Restart command stderr: %@", error]];
        }

        if (!executionError && [output containsString:@"Restarting device"]) {
            success = YES;
            [self notifyLog:@"✓ Second restart command accepted by device"];
        } else {
            [self notifyLog:[NSString stringWithFormat:@"✗ Restart failed - error: %@", executionError.localizedDescription ?: @"output missing 'Restarting device'"]];
            [self notifyCompletion:NO message:@"Trust Device or check connection USB Cable!"];
        }

        dispatch_semaphore_signal(semaphore);
    }];

    long result = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    if (result != 0) {
        [self notifyLog:@"✗ Restart command timed out after 30 seconds"];
        success = NO;
    }

    if (!success) {
        [self stopPHPServer];
    }
    return success;
}

// Wait for device restart with countdown
- (void)waitForRestart:(NSInteger)seconds restartNumber:(NSInteger)restartNumber {
    NSInteger baseProgress = (restartNumber == 1) ? 60 : 80;

    for (NSInteger i = seconds; i >= 0; i--) {
        if (self.isCancelled) {
            return;
        }

        NSString *message = [NSString stringWithFormat:@"Please wait for reboot after: %ld seconds", (long)i];
        [self notifyProgress:baseProgress message:message];

        [NSThread sleepForTimeInterval:1.0];
    }

    NSInteger completionProgress = (restartNumber == 1) ? 70 : 90;
    [self notifyProgress:completionProgress message:@"Restarting your device is completed now..."];
}

// Step 6: Verify activation via mobilegestalt
- (void)verifyActivation {
    [self notifyProgress:80 message:@"Checking activation status, please wait..."];
    [self notifyLog:@"Starting MobileGestalt verification..."];

    // First check: hactivation key
    [self notifyLog:@"→ Checking hactivation key..."];
    [self checkMobileGestaltKey:@"hactivation" completion:^(BOOL success) {
        if (!success) {
            [self notifyLog:@"✗ FAILED: hactivation check returned false"];
            [self notifyLog:@"This means the payload was not properly processed by the device"];
            [self notifyCompletion:NO message:@"[M] Failed to activate your device, please retry the process.."];
            return;
        }

        [self notifyLog:@"✓ PASSED: hactivation check successful"];
        [self notifyProgress:80 message:@"Activating your device, please wait.."];
        [NSThread sleepForTimeInterval:5.0];

        // Second check: ShouldHactivate key
        [self notifyLog:@"→ Checking ShouldHactivate key..."];
        [self checkMobileGestaltKey:@"ShouldHactivate" completion:^(BOOL shouldActivate) {
            if (shouldActivate) {
                [self notifyLog:@"✓ PASSED: ShouldHactivate returned true"];
                [self notifyLog:@"✓✓✓ ACTIVATION SUCCESSFUL! ✓✓✓"];
                [self notifyProgress:100 message:@"Rebooting your device, please wait..."];
                [NSThread sleepForTimeInterval:5.0];

                // Final restart
                [self notifyLog:@"Performing final restart..."];
                [self performFinalRestart];

                [self notifyCompletion:YES message:@"Your Device was Successfully Activated and it's rebooting now. Please complete activation as normal."];
            } else {
                [self notifyLog:@"✗ FAILED: ShouldHactivate returned false"];
                [self notifyLog:@"Possible reasons:"];
                [self notifyLog:@"  1. Device not connected to WiFi"];
                [self notifyLog:@"  2. iOS version not supported"];
                [self notifyLog:@"  3. Payload didn't persist through reboots"];
                [self notifyLog:@"  4. Device model/build mismatch"];
                [self notifyCompletion:NO message:@"[Gestalt] Failed activate, please connect to wifi on device and try again or use different ios version"];
            }
        }];
    }];
}

- (void)checkMobileGestaltKey:(NSString *)key completion:(void(^)(BOOL success))completion {
    NSArray *arguments = @[@"mobilegestalt", @"KEY", key];

    [self notifyLog:[NSString stringWithFormat:@"Checking MobileGestalt key: %@", key]];

    [A5CommandExecutor executeCommand:[A5Constants idevicediagnosticsTool]
                            arguments:arguments
                           completion:^(NSString *output, NSString *error, NSError *executionError) {
        BOOL success = NO;

        // Log the raw output for debugging
        [self notifyLog:[NSString stringWithFormat:@"MobileGestalt output for '%@':", key]];
        [self notifyLog:[NSString stringWithFormat:@"  stdout: %@", output ?: @"(empty)"]];
        if (error && error.length > 0) {
            [self notifyLog:[NSString stringWithFormat:@"  stderr: %@", error]];
        }
        if (executionError) {
            [self notifyLog:[NSString stringWithFormat:@"  error: %@", executionError.localizedDescription]];
        }

        if ([key isEqualToString:@"hactivation"]) {
            // Check for "MobileGestalt" and "Success" in output
            success = [output containsString:@"MobileGestalt"] && [output containsString:@"Success"];
            [self notifyLog:[NSString stringWithFormat:@"  hactivation check: %@", success ? @"PASS" : @"FAIL"]];
        } else if ([key isEqualToString:@"ShouldHactivate"]) {
            // Check for "true" in output
            success = [output containsString:@"true"];
            [self notifyLog:[NSString stringWithFormat:@"  ShouldHactivate check: %@ (looking for 'true')", success ? @"PASS" : @"FAIL"]];
        }

        completion(success);
    }];
}

- (void)performFinalRestart {
    [A5CommandExecutor executeCommand:[A5Constants idevicediagnosticsTool]
                            arguments:@[@"restart"]
                           completion:^(NSString *output, NSString *error, NSError *executionError) {
        // Final restart, no need to wait for result
        [self notifyLog:@"Final restart initiated"];
    }];
}

#pragma mark - PHP Server Management

- (BOOL)startPHPServerForDevice:(NSString *)udid {
    [self notifyLog:@"Starting backend infrastructure..."];

    // Get backend directory path from bundle
    NSString *backendPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"backend"];

    if (!backendPath || ![[NSFileManager defaultManager] fileExistsAtPath:backendPath]) {
        [self notifyLog:[NSString stringWithFormat:@"✗ Backend not found at: %@", backendPath]];
        return NO;
    }
    [self notifyLog:[NSString stringWithFormat:@"✓ Backend path: %@", backendPath]];

    // Stop any existing servers
    [self stopPHPServer];

    // NOTE: iproxy is NOT needed for local backend!
    // iOS devices connected via USB automatically get network connectivity to Mac.
    // The device will connect to Mac.local:8080 over USB network interface.
    // iproxy only supports Mac→Device tunneling, not Device→Mac (which we need).
    [self notifyLog:@"ℹ️ Local backend uses USB network (no iproxy needed)"];

    // Start native HTTP backend server on ALL interfaces (not just 127.0.0.1)
    [self notifyLog:@"Starting HTTP backend server on port 8080 (all interfaces)..."];
    self.backendServer = [[A5BackendServer alloc] init];

    // Set up log handler to forward backend logs to UI
    __weak typeof(self) weakSelf = self;
    self.backendServer.logHandler = ^(NSString *message) {
        [weakSelf notifyLog:message];
    };

    if (![self.backendServer startServerOnPort:8080 withBackendPath:backendPath]) {
        [self notifyLog:@"✗ Backend server failed to bind to port 8080"];
        [self stopPHPServer];
        return NO;
    }

    [self notifyLog:@"✓ Backend server listening on port 8080 (accessible via USB)"];
    [self notifyLog:@"ℹ️ Device will connect to Mac.local:8080 over USB network"];
    [NSThread sleepForTimeInterval:0.5];

    return YES;
}

- (void)stopPHPServer {
    if (self.backendServer && self.backendServer.isRunning) {
        [self.backendServer stopServer];
        [self notifyLog:@"Backend server stopped"];
    }
    self.backendServer = nil;

    // iproxyTask removed - no longer needed for local backend
}

#pragma mark - Delegate Notifications

- (void)notifyProgress:(NSInteger)percentage message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(activationProgressUpdated:message:)]) {
            [self.delegate activationProgressUpdated:percentage message:message];
        }
    });
}

- (void)notifyCompletion:(BOOL)success message:(NSString *)message {
    // Stop PHP server when activation completes or fails
    [self stopPHPServer];

    // Close log file and notify user
    if (self.logFileHandle) {
        NSString *footer = [NSString stringWithFormat:@"\n%@\nActivation %@\nLog saved to: %@\n",
                           @"=================================================================",
                           success ? @"SUCCEEDED" : @"FAILED",
                           self.logFilePath];
        [self.logFileHandle writeData:[footer dataUsingEncoding:NSUTF8StringEncoding]];
        [self.logFileHandle closeFile];
        self.logFileHandle = nil;

        NSLog(@"[A5] Log file closed: %@", self.logFilePath);

        // Show file location in UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(activationLogMessage:)]) {
                [self.delegate activationLogMessage:[NSString stringWithFormat:@"📄 Complete log saved to Desktop: A5_Activation_Log_*.txt"]];
            }
        });
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(activationCompleted:message:)]) {
            [self.delegate activationCompleted:success message:message];
        }
    });
}

- (void)setupLogFile {
    // Create log file in user's Desktop with timestamp
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd_HH-mm-ss";
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];

    NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) firstObject];
    self.logFilePath = [desktopPath stringByAppendingPathComponent:[NSString stringWithFormat:@"A5_Activation_Log_%@.txt", timestamp]];

    // Create file
    [[NSFileManager defaultManager] createFileAtPath:self.logFilePath contents:nil attributes:nil];
    self.logFileHandle = [NSFileHandle fileHandleForWritingAtPath:self.logFilePath];

    if (self.logFileHandle) {
        NSString *header = [NSString stringWithFormat:@"A5 Activation Log - %@\n%@\n\n",
                           [[NSDate date] description],
                           @"================================================================="];
        [self.logFileHandle writeData:[header dataUsingEncoding:NSUTF8StringEncoding]];

        NSLog(@"[A5] Log file created: %@", self.logFilePath);
    }
}

- (void)notifyLog:(NSString *)message {
    // Write to file
    if (self.logFileHandle) {
        NSString *logLine = [NSString stringWithFormat:@"%@\n", message];
        [self.logFileHandle writeData:[logLine dataUsingEncoding:NSUTF8StringEncoding]];
    }

    // Send to UI
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(activationLogMessage:)]) {
            [self.delegate activationLogMessage:message];
        }
    });
}

@end
