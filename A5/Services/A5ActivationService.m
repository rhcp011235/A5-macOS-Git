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

@interface A5ActivationService ()

@property (assign, nonatomic) BOOL isCancelled;
@property (strong, nonatomic) dispatch_queue_t activationQueue;
@property (strong, nonatomic, nullable) A5BackendServer *backendServer;
@property (strong, nonatomic, nullable) NSTask *iproxyTask;

@end

@implementation A5ActivationService

- (instancetype)init {
    self = [super init];
    if (self) {
        _isCancelled = NO;
        _activationQueue = dispatch_queue_create("com.a5.activation", DISPATCH_QUEUE_SERIAL);
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
    // Step 0: Start local PHP server for backend
    if (![self startPHPServerForDevice:udid]) {
        [self notifyCompletion:NO message:@"Failed to start backend server"];
        return;
    }

    // Step 1: Transfer payload (20%)
    if (![self transferPayload:udid]) {
        [self stopPHPServer];
        return;
    }

    if (self.isCancelled) return;

    // Step 2: First device restart (60%)
    if (![self performFirstRestart]) {
        return;
    }

    if (self.isCancelled) return;

    // Step 3: Wait 90 seconds
    [self waitForRestart:90 restartNumber:1];

    if (self.isCancelled) return;

    // Step 4: Second device restart (80%)
    if (![self performSecondRestart]) {
        return;
    }

    if (self.isCancelled) return;

    // Step 5: Wait 90 seconds
    [self waitForRestart:90 restartNumber:2];

    if (self.isCancelled) return;

    // Step 6: Verify activation (100%)
    [self verifyActivation];
}

// Step 1: Transfer activation payload to device
- (BOOL)transferPayload:(NSString *)udid {
    [self notifyProgress:20 message:@"Preparing your device info, please wait..."];

    // Get payload path from bundle
    NSString *payloadPath = [[NSBundle mainBundle] pathForResource:[A5Constants activationPayloadName]
                                                             ofType:nil
                                                        inDirectory:[A5Constants payloadsDirectoryName]];

    if (!payloadPath || ![[NSFileManager defaultManager] fileExistsAtPath:payloadPath]) {
        [self notifyCompletion:NO message:@"Activation payload not found in bundle"];
        return NO;
    }

    // Copy payload to temporary location
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"A5_payload"];
    NSError *copyError = nil;

    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];  // Remove if exists
    [[NSFileManager defaultManager] copyItemAtPath:payloadPath toPath:tempPath error:&copyError];

    if (copyError) {
        [self notifyCompletion:NO message:[NSString stringWithFormat:@"Failed to prepare payload: %@", copyError.localizedDescription]];
        return NO;
    }

    // Execute afcclient to transfer file
    // Command: afcclient put --udid <udid> <source> /Downloads/downloads.28.sqlitedb
    NSArray *arguments = @[@"put", @"--udid", udid, tempPath, @"/Downloads/downloads.28.sqlitedb"];

    __block BOOL success = NO;
    __block NSString *errorMessage = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [A5CommandExecutor executeCommand:[A5Constants afcclientTool]
                            arguments:arguments
                           completion:^(NSString *output, NSString *error, NSError *executionError) {
        if (executionError) {
            errorMessage = [NSString stringWithFormat:@"AFC transfer failed: %@", executionError.localizedDescription];
        } else if ([error containsString:@"ERROR"] || [error containsString:@"error"]) {
            errorMessage = @"AFC file transfer error";
        } else {
            success = YES;
            [self notifyLog:@"Payload transferred successfully"];
        }

        // Clean up temp file
        [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];

        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    if (!success) {
        [self notifyCompletion:NO message:errorMessage ?: @"Payload transfer failed"];
        return NO;
    }

    return YES;
}

// Step 2: First device restart
- (BOOL)performFirstRestart {
    [self notifyProgress:60 message:@"[1] Restarting your device, please wait..."];

    __block BOOL success = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [A5CommandExecutor executeCommand:[A5Constants idevicediagnosticsTool]
                            arguments:@[@"restart"]
                           completion:^(NSString *output, NSString *error, NSError *executionError) {
        if (!executionError && [output containsString:@"Restarting device"]) {
            success = YES;
            [self notifyLog:@"First restart initiated"];
        } else {
            [self notifyCompletion:NO message:@"Trust Device or check connection USB Cable!"];
        }

        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

// Step 4: Second device restart
- (BOOL)performSecondRestart {
    [self notifyProgress:80 message:@"[2] Restarting your device, please wait..."];

    __block BOOL success = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [A5CommandExecutor executeCommand:[A5Constants idevicediagnosticsTool]
                            arguments:@[@"restart"]
                           completion:^(NSString *output, NSString *error, NSError *executionError) {
        if (!executionError && [output containsString:@"Restarting device"]) {
            success = YES;
            [self notifyLog:@"Second restart initiated"];
        } else {
            [self notifyCompletion:NO message:@"Trust Device or check connection USB Cable!"];
        }

        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
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

    // First check: hactivation key
    [self checkMobileGestaltKey:@"hactivation" completion:^(BOOL success) {
        if (!success) {
            [self notifyCompletion:NO message:@"[M] Failed to activate your device, please retry the process.."];
            return;
        }

        [self notifyProgress:80 message:@"Activating your device, please wait.."];
        [NSThread sleepForTimeInterval:5.0];

        // Second check: ShouldHactivate key
        [self checkMobileGestaltKey:@"ShouldHactivate" completion:^(BOOL shouldActivate) {
            if (shouldActivate) {
                [self notifyProgress:100 message:@"Rebooting your device, please wait..."];
                [NSThread sleepForTimeInterval:5.0];

                // Final restart
                [self performFinalRestart];

                [self notifyCompletion:YES message:@"Your Device was Successfully Activated and it's rebooting now. Please complete activation as normal."];
            } else {
                [self notifyCompletion:NO message:@"[Gestalt] Failed activate, please connect to wifi on device and try again or use different ios version"];
            }
        }];
    }];
}

- (void)checkMobileGestaltKey:(NSString *)key completion:(void(^)(BOOL success))completion {
    NSArray *arguments = @[@"mobilegestalt", @"KEY", key];

    [A5CommandExecutor executeCommand:[A5Constants idevicediagnosticsTool]
                            arguments:arguments
                           completion:^(NSString *output, NSString *error, NSError *executionError) {
        BOOL success = NO;

        if ([key isEqualToString:@"hactivation"]) {
            // Check for "MobileGestalt" and "Success" in output
            success = [output containsString:@"MobileGestalt"] && [output containsString:@"Success"];
        } else if ([key isEqualToString:@"ShouldHactivate"]) {
            // Check for "true" in output
            success = [output containsString:@"true"];
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
    // Get backend directory path from bundle
    NSString *backendPath = [[NSBundle mainBundle] pathForResource:@"backend" ofType:nil inDirectory:@"Resources"];

    if (!backendPath || ![[NSFileManager defaultManager] fileExistsAtPath:backendPath]) {
        [self notifyLog:@"Backend server files not found in bundle"];
        return NO;
    }

    // Get iproxy path from bundle or system
    NSString *iproxyPath = [A5CommandExecutor pathForTool:[A5Constants iproxyTool]];
    if (!iproxyPath) {
        [self notifyLog:@"iproxy not found in bundle"];
        return NO;
    }

    // Stop any existing servers
    [self stopPHPServer];

    // Start iproxy for USB port forwarding (device port 8080 -> Mac port 8080)
    self.iproxyTask = [[NSTask alloc] init];
    self.iproxyTask.launchPath = iproxyPath;
    self.iproxyTask.arguments = @[@"-u", udid, @"8080", @"8080"];

    NSPipe *iproxyOutputPipe = [NSPipe pipe];
    NSPipe *iproxyErrorPipe = [NSPipe pipe];
    self.iproxyTask.standardOutput = iproxyOutputPipe;
    self.iproxyTask.standardError = iproxyErrorPipe;

    @try {
        [self.iproxyTask launch];
        [self notifyLog:@"USB port forwarding started (iproxy 8080:8080)"];
        [NSThread sleepForTimeInterval:0.5];
    } @catch (NSException *exception) {
        [self notifyLog:[NSString stringWithFormat:@"Failed to start iproxy: %@", exception.reason]];
        self.iproxyTask = nil;
        return NO;
    }

    // Start native HTTP backend server
    self.backendServer = [[A5BackendServer alloc] init];
    if (![self.backendServer startServerOnPort:8080 withBackendPath:backendPath]) {
        [self notifyLog:@"Failed to start backend server on port 8080"];
        [self stopPHPServer];
        return NO;
    }

    [self notifyLog:@"Backend server started on localhost:8080"];
    [NSThread sleepForTimeInterval:0.5];

    return YES;
}

- (void)stopPHPServer {
    if (self.backendServer && self.backendServer.isRunning) {
        [self.backendServer stopServer];
        [self notifyLog:@"Backend server stopped"];
    }
    self.backendServer = nil;

    if (self.iproxyTask && self.iproxyTask.isRunning) {
        [self.iproxyTask terminate];
        [self notifyLog:@"USB port forwarding stopped"];
    }
    self.iproxyTask = nil;
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

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(activationCompleted:message:)]) {
            [self.delegate activationCompleted:success message:message];
        }
    });
}

- (void)notifyLog:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(activationLogMessage:)]) {
            [self.delegate activationLogMessage:message];
        }
    });
}

@end
