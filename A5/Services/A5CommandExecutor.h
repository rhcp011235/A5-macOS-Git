//
//  A5CommandExecutor.h
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//
//  NSTask wrapper for executing libimobiledevice tools
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^A5CommandCompletion)(NSString * _Nullable output, NSString * _Nullable error, NSError * _Nullable executionError);

@interface A5CommandExecutor : NSObject

/**
 * Execute a tool from the bundle's Tools directory
 * @param toolName Name of the tool (e.g., "idevice_id")
 * @param arguments Array of string arguments
 * @param completion Callback with output, error, and execution error
 */
+ (void)executeCommand:(NSString *)toolName
             arguments:(NSArray<NSString *> * _Nullable)arguments
            completion:(A5CommandCompletion)completion;

/**
 * Execute a tool synchronously (blocking)
 * @param toolName Name of the tool
 * @param arguments Array of string arguments
 * @param output Pointer to NSString for stdout
 * @param error Pointer to NSString for stderr
 * @return YES if successful, NO if failed
 */
+ (BOOL)executeCommandSync:(NSString *)toolName
                 arguments:(NSArray<NSString *> * _Nullable)arguments
                    output:(NSString *_Nullable *_Nullable)output
                     error:(NSString *_Nullable *_Nullable)error;

/**
 * Get the full path to a tool in the bundle
 * @param toolName Name of the tool
 * @return Full path to the tool, or nil if not found
 */
+ (NSString * _Nullable)pathForTool:(NSString *)toolName;

@end

NS_ASSUME_NONNULL_END
