//
//  A5DeviceData.h
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface A5DeviceData : NSObject

@property (strong, nonatomic, nullable) NSString *guid;
@property (strong, nonatomic, nullable) NSString *udid;
@property (strong, nonatomic, nullable) NSString *productType;
@property (strong, nonatomic, nullable) NSString *productVersion;
@property (strong, nonatomic, nullable) NSString *buildVersion;
@property (strong, nonatomic, nullable) NSString *serialNumber;
@property (strong, nonatomic, nullable) NSString *activationState;
@property (strong, nonatomic, nullable) NSString *imei;
@property (strong, nonatomic, nullable) NSString *meid;
@property (strong, nonatomic, nullable) NSString *ecid;
@property (strong, nonatomic, nullable) NSString *modelName;
@property (strong, nonatomic, nullable) NSString *deviceName;
@property (strong, nonatomic, nullable) NSString *simStatus;

- (BOOL)isValid;
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
