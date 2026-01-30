//
//  A5DeviceManager.h
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//
//  Device detection and information retrieval service
//

#import <Foundation/Foundation.h>
#import "A5DeviceData.h"

NS_ASSUME_NONNULL_BEGIN

@protocol A5DeviceManagerDelegate <NSObject>

@optional
- (void)deviceConnected:(A5DeviceData *)deviceData;
- (void)deviceDisconnected;
- (void)deviceInfoUpdated:(A5DeviceData *)deviceData;

@end

@interface A5DeviceManager : NSObject

@property (weak, nonatomic, nullable) id<A5DeviceManagerDelegate> delegate;
@property (strong, nonatomic, readonly, nullable) A5DeviceData *currentDevice;
@property (assign, nonatomic, readonly) BOOL isDeviceConnected;

/**
 * Get UDID of connected device
 * @return UDID string or nil if no device connected
 */
- (NSString * _Nullable)getDeviceUDID;

/**
 * Get device information for a specific UDID
 * @param udid Device UDID
 * @param completion Callback with device data or error
 */
- (void)getDeviceInfo:(NSString *)udid
           completion:(void(^)(A5DeviceData * _Nullable deviceData, NSError * _Nullable error))completion;

/**
 * Check for connected devices and update state
 * Called by timer every 3 seconds
 */
- (void)checkForDevices;

/**
 * Start device monitoring
 */
- (void)startMonitoring;

/**
 * Stop device monitoring
 */
- (void)stopMonitoring;

@end

NS_ASSUME_NONNULL_END
