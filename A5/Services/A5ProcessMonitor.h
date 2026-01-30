//
//  A5ProcessMonitor.h
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//
//  Process monitoring and termination service for macOS
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol A5ProcessMonitorDelegate <NSObject>

@optional
- (void)processKilled:(NSString *)processName pid:(pid_t)pid;
- (void)processMonitorLogMessage:(NSString *)message;

@end

@interface A5ProcessMonitor : NSObject

@property (weak, nonatomic, nullable) id<A5ProcessMonitorDelegate> delegate;
@property (assign, nonatomic, readonly) BOOL isMonitoring;

/**
 * Start monitoring processes in background
 */
- (void)startMonitoring;

/**
 * Stop monitoring processes
 */
- (void)stopMonitoring;

/**
 * Kill a specific process by name
 * @param processName Name of the process to kill
 * @return YES if process was found and killed
 */
- (BOOL)killProcessByName:(NSString *)processName;

/**
 * Check if a process is currently running
 * @param processName Name of the process
 * @return YES if process is running
 */
- (BOOL)isProcessRunning:(NSString *)processName;

/**
 * Get list of currently running suspicious processes
 * @return Array of process names with PIDs
 */
- (NSArray<NSString *> *)getRunningSuspiciousProcesses;

@end

NS_ASSUME_NONNULL_END
