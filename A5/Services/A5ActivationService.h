//
//  A5ActivationService.h
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//
//  Activation workflow orchestrator for A5 devices
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol A5ActivationServiceDelegate <NSObject>

@optional
- (void)activationProgressUpdated:(NSInteger)percentage message:(NSString *)message;
- (void)activationCompleted:(BOOL)success message:(NSString *)message;
- (void)activationLogMessage:(NSString *)message;

@end

@interface A5ActivationService : NSObject

@property (weak, nonatomic, nullable) id<A5ActivationServiceDelegate> delegate;

/**
 * Start activation process for device
 * @param udid Device UDID
 *
 * Workflow:
 * 1. Transfer payload (20%)
 * 2. First restart (60%) + wait 90s
 * 3. Second restart (80%) + wait 90s
 * 4. Verify activation (100%)
 */
- (void)activateDevice:(NSString *)udid;

/**
 * Cancel activation process
 */
- (void)cancelActivation;

@end

NS_ASSUME_NONNULL_END
