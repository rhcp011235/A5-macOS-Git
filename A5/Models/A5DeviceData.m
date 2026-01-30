//
//  A5DeviceData.m
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import "A5DeviceData.h"

@implementation A5DeviceData

- (instancetype)init {
    self = [super init];
    if (self) {
        _guid = nil;
        _udid = nil;
        _productType = nil;
        _productVersion = nil;
        _buildVersion = nil;
        _serialNumber = nil;
        _activationState = @"Unactivated";
        _imei = nil;
        _meid = nil;
        _ecid = nil;
        _modelName = @"Unknown Device";
        _deviceName = nil;
        _simStatus = nil;
    }
    return self;
}

- (BOOL)isValid {
    return self.udid != nil && self.udid.length > 0;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.guid) dict[@"guid"] = self.guid;
    if (self.udid) dict[@"udid"] = self.udid;
    if (self.productType) dict[@"productType"] = self.productType;
    if (self.productVersion) dict[@"productVersion"] = self.productVersion;
    if (self.buildVersion) dict[@"buildVersion"] = self.buildVersion;
    if (self.serialNumber) dict[@"serialNumber"] = self.serialNumber;
    if (self.activationState) dict[@"activationState"] = self.activationState;
    if (self.imei) dict[@"imei"] = self.imei;
    if (self.meid) dict[@"meid"] = self.meid;
    if (self.ecid) dict[@"ecid"] = self.ecid;
    if (self.modelName) dict[@"modelName"] = self.modelName;
    if (self.deviceName) dict[@"deviceName"] = self.deviceName;
    if (self.simStatus) dict[@"simStatus"] = self.simStatus;

    return [dict copy];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"A5DeviceData: %@ (%@) - %@ %@",
            self.modelName ?: @"Unknown",
            self.productType ?: @"N/A",
            self.productVersion ?: @"N/A",
            self.activationState ?: @"N/A"];
}

@end
