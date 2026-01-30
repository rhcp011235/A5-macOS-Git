//
//  A5DeviceModelMapper.h
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//
//  Device model mapping using FNV-1a hash algorithm
//  Equivalent to iOSDevice2.cs CalculateModelNumber() and DetermineModel()
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface A5DeviceModelMapper : NSObject

/**
 * Calculate FNV-1a hash for product type string
 * FNV-1a hash function from iOSDevice2.cs lines 88-98
 */
+ (uint32_t)calculateHashForProductType:(NSString *)productType;

/**
 * Map product type to human-readable model name
 * Returns device model name or "Unknown Device" if not found
 */
+ (NSString *)modelNameForProductType:(NSString *)productType;

/**
 * Check if device is A5 chip (iPhone 4S, iPhone 5/5c, iPad 2)
 */
+ (BOOL)isA5Device:(NSString *)productType;

@end

NS_ASSUME_NONNULL_END
