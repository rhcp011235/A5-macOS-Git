//
//  A5CommandExecutor.m
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import "A5CommandExecutor.h"
#import "A5Constants.h"

@implementation A5CommandExecutor

+ (NSString *)pathForTool:(NSString *)toolName {
    // First try to find in bundle's Tools directory
    NSString *toolPath = [[NSBundle mainBundle] pathForResource:toolName
                                                          ofType:nil
                                                     inDirectory:[A5Constants toolsDirectoryName]];

    if (toolPath && [[NSFileManager defaultManager] fileExistsAtPath:toolPath]) {
        return toolPath;
    }

    // Fallback: try to find in system PATH
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/which";
    task.arguments = @[toolName];

    NSPipe *outputPipe = [NSPipe pipe];
    task.standardOutput = outputPipe;
    task.standardError = [NSPipe pipe];

    @try {
        [task launch];
        [task waitUntilExit];

        if (task.terminationStatus == 0) {
            NSData *outputData = [[outputPipe fileHandleForReading] readDataToEndOfFile];
            NSString *path = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
            path = [path stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            if (path.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
                return path;
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Error finding tool %@: %@", toolName, exception);
    }

    return nil;
}

+ (void)executeCommand:(NSString *)toolName
             arguments:(NSArray<NSString *> *)arguments
            completion:(A5CommandCompletion)completion {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *toolPath = [self pathForTool:toolName];

        if (!toolPath) {
            NSError *error = [NSError errorWithDomain:@"A5CommandExecutor"
                                                 code:1001
                                             userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Tool not found: %@", toolName]}];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil, error);
            });
            return;
        }

        NSTask *task = [[NSTask alloc] init];
        task.launchPath = toolPath;
        task.arguments = arguments ?: @[];

        NSPipe *outputPipe = [NSPipe pipe];
        NSPipe *errorPipe = [NSPipe pipe];
        task.standardOutput = outputPipe;
        task.standardError = errorPipe;

        @try {
            [task launch];
            [task waitUntilExit];

            NSData *outputData = [[outputPipe fileHandleForReading] readDataToEndOfFile];
            NSData *errorData = [[errorPipe fileHandleForReading] readDataToEndOfFile];

            NSString *output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
            NSString *errorOutput = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];

            NSError *executionError = nil;
            if (task.terminationStatus != 0) {
                executionError = [NSError errorWithDomain:@"A5CommandExecutor"
                                                     code:task.terminationStatus
                                                 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Command failed with exit code %d", task.terminationStatus]}];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                completion(output, errorOutput, executionError);
            });

        } @catch (NSException *exception) {
            NSError *error = [NSError errorWithDomain:@"A5CommandExecutor"
                                                 code:1002
                                             userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Command execution failed: %@", exception.reason]}];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil, error);
            });
        }
    });
}

+ (BOOL)executeCommandSync:(NSString *)toolName
                 arguments:(NSArray<NSString *> *)arguments
                    output:(NSString **)output
                     error:(NSString **)error {

    NSString *toolPath = [self pathForTool:toolName];

    if (!toolPath) {
        if (error) {
            *error = [NSString stringWithFormat:@"Tool not found: %@", toolName];
        }
        return NO;
    }

    NSTask *task = [[NSTask alloc] init];
    task.launchPath = toolPath;
    task.arguments = arguments ?: @[];

    NSPipe *outputPipe = [NSPipe pipe];
    NSPipe *errorPipe = [NSPipe pipe];
    task.standardOutput = outputPipe;
    task.standardError = errorPipe;

    @try {
        [task launch];
        [task waitUntilExit];

        NSData *outputData = [[outputPipe fileHandleForReading] readDataToEndOfFile];
        NSData *errorData = [[errorPipe fileHandleForReading] readDataToEndOfFile];

        if (output) {
            *output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        }

        if (error) {
            *error = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        }

        return task.terminationStatus == 0;

    } @catch (NSException *exception) {
        if (error) {
            *error = [NSString stringWithFormat:@"Command execution failed: %@", exception.reason];
        }
        return NO;
    }
}

@end
