//
//  A5DeviceManager.m
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import "A5DeviceManager.h"
#import "A5CommandExecutor.h"
#import "A5DeviceModelMapper.h"
#import "A5Constants.h"

@interface A5DeviceManager ()

@property (strong, nonatomic, readwrite) A5DeviceData *currentDevice;
@property (assign, nonatomic, readwrite) BOOL isDeviceConnected;
@property (strong, nonatomic) NSTimer *monitoringTimer;
@property (strong, nonatomic) NSString *lastUDID;

@end

@implementation A5DeviceManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _isDeviceConnected = NO;
        _currentDevice = nil;
        _lastUDID = nil;
    }
    return self;
}

- (void)dealloc {
    [self stopMonitoring];
}

#pragma mark - Public Methods

- (NSString *)getDeviceUDID {
    NSString *output = nil;
    NSString *error = nil;

    BOOL success = [A5CommandExecutor executeCommandSync:[A5Constants ideviceIdTool]
                                                arguments:@[@"-l"]
                                                   output:&output
                                                    error:&error];

    if (success && output && output.length > 0) {
        NSArray *lines = [output componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        for (NSString *line in lines) {
            NSString *trimmedLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (trimmedLine.length > 0) {
                return trimmedLine;  // Return first UDID
            }
        }
    }

    return nil;
}

- (void)getDeviceInfo:(NSString *)udid completion:(void (^)(A5DeviceData * _Nullable, NSError * _Nullable))completion {
    if (!udid || udid.length == 0) {
        NSError *error = [NSError errorWithDomain:@"A5DeviceManager"
                                             code:2001
                                         userInfo:@{NSLocalizedDescriptionKey: @"UDID is required"}];
        completion(nil, error);
        return;
    }

    [A5CommandExecutor executeCommand:[A5Constants ideviceinfoTool]
                            arguments:@[@"-u", udid]
                           completion:^(NSString *output, NSString *error, NSError *executionError) {
        if (executionError) {
            // Check if lockdown error
            if ([error containsString:@"invalid HostID"] ||
                [error containsString:@"Could not connect to lockdownd"] ||
                [error containsString:@"Lockdown error"]) {

                NSLog(@"Lockdown error detected, attempting cleanup...");
                [self cleanupLockdownData];

                // Retry after cleanup
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self getDeviceInfo:udid completion:completion];
                });
                return;
            }

            completion(nil, executionError);
            return;
        }

        if (!output || output.length == 0) {
            NSError *err = [NSError errorWithDomain:@"A5DeviceManager"
                                               code:2002
                                           userInfo:@{NSLocalizedDescriptionKey: @"No device info received"}];
            completion(nil, err);
            return;
        }

        // Parse device info
        A5DeviceData *deviceData = [self parseDeviceInfo:output udid:udid];
        completion(deviceData, nil);
    }];
}

- (void)checkForDevices {
    NSString *udid = [self getDeviceUDID];

    if (udid && udid.length > 0) {
        // Device is connected
        if (!self.isDeviceConnected || ![udid isEqualToString:self.lastUDID]) {
            // New device connected or different device
            self.lastUDID = udid;
            self.isDeviceConnected = YES;

            [self getDeviceInfo:udid completion:^(A5DeviceData *deviceData, NSError *error) {
                if (error) {
                    NSLog(@"Error getting device info: %@", error.localizedDescription);
                    return;
                }

                self.currentDevice = deviceData;

                if ([self.delegate respondsToSelector:@selector(deviceConnected:)]) {
                    [self.delegate deviceConnected:deviceData];
                }
            }];
        } else {
            // Same device, update info
            [self getDeviceInfo:udid completion:^(A5DeviceData *deviceData, NSError *error) {
                if (error) {
                    return;
                }

                self.currentDevice = deviceData;

                if ([self.delegate respondsToSelector:@selector(deviceInfoUpdated:)]) {
                    [self.delegate deviceInfoUpdated:deviceData];
                }
            }];
        }
    } else {
        // No device connected
        if (self.isDeviceConnected) {
            self.isDeviceConnected = NO;
            self.currentDevice = nil;
            self.lastUDID = nil;

            if ([self.delegate respondsToSelector:@selector(deviceDisconnected)]) {
                [self.delegate deviceDisconnected];
            }
        }
    }
}

- (void)startMonitoring {
    if (self.monitoringTimer) {
        return;  // Already monitoring
    }

    // Initial check
    [self checkForDevices];

    // Setup timer for periodic checks
    self.monitoringTimer = [NSTimer scheduledTimerWithTimeInterval:[A5Constants deviceCheckInterval]
                                                            target:self
                                                          selector:@selector(checkForDevices)
                                                          userInfo:nil
                                                           repeats:YES];
}

- (void)stopMonitoring {
    if (self.monitoringTimer) {
        [self.monitoringTimer invalidate];
        self.monitoringTimer = nil;
    }
}

#pragma mark - Private Methods

- (A5DeviceData *)parseDeviceInfo:(NSString *)output udid:(NSString *)udid {
    A5DeviceData *deviceData = [[A5DeviceData alloc] init];
    deviceData.udid = udid;

    // Parse key-value pairs from ideviceinfo output
    // Format: "Key: Value"
    NSMutableDictionary *deviceInfo = [NSMutableDictionary dictionary];

    NSArray *lines = [output componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines) {
        NSRange colonRange = [line rangeOfString:@":"];
        if (colonRange.location != NSNotFound && colonRange.location > 0) {
            NSString *key = [[line substringToIndex:colonRange.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *value = [[line substringFromIndex:colonRange.location + 1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            if (key.length > 0 && value.length > 0) {
                deviceInfo[key] = value;
            }
        }
    }

    // Extract device properties
    deviceData.productType = [self getValueFromDict:deviceInfo forKey:@"ProductType" defaultValue:nil];
    deviceData.productVersion = [self getValueFromDict:deviceInfo forKey:@"ProductVersion" defaultValue:nil];
    deviceData.buildVersion = [self getValueFromDict:deviceInfo forKey:@"BuildVersion" defaultValue:nil];
    deviceData.serialNumber = [self getValueFromDict:deviceInfo forKey:@"SerialNumber" defaultValue:nil];
    deviceData.activationState = [self getValueFromDict:deviceInfo forKey:@"ActivationState" defaultValue:@"Unactivated"];
    deviceData.imei = [self getValueFromDict:deviceInfo forKey:@"InternationalMobileEquipmentIdentity" defaultValue:nil];
    deviceData.meid = [self getValueFromDict:deviceInfo forKey:@"MobileEquipmentIdentifier" defaultValue:nil];
    deviceData.deviceName = [self getValueFromDict:deviceInfo forKey:@"DeviceName" defaultValue:nil];
    deviceData.simStatus = [self getValueFromDict:deviceInfo forKey:@"SIMStatus" defaultValue:nil];

    // UniqueChipID (ECID) is returned as decimal, convert to hex
    NSString *ecidDecimal = [self getValueFromDict:deviceInfo forKey:@"UniqueChipID" defaultValue:nil];
    if (ecidDecimal) {
        unsigned long long ecidValue = strtoull([ecidDecimal UTF8String], NULL, 10);
        deviceData.ecid = [NSString stringWithFormat:@"0x%llX", ecidValue];
    }

    // Determine model name using FNV-1a hash
    if (deviceData.productType) {
        deviceData.modelName = [A5DeviceModelMapper modelNameForProductType:deviceData.productType];
    }

    return deviceData;
}

- (NSString *)getValueFromDict:(NSDictionary *)dict forKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    NSString *value = dict[key];
    if (!value || [value isEqualToString:@"(null)"] || value.length == 0) {
        return defaultValue;
    }
    return value;
}

- (void)cleanupLockdownData {
    // macOS lockdown directory is typically at ~/Library/Lockdown
    NSString *lockdownPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Lockdown"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:lockdownPath]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:lockdownPath error:&error];
        if (error) {
            NSLog(@"Error cleaning lockdown data: %@", error.localizedDescription);
        } else {
            NSLog(@"Lockdown data cleaned successfully");
        }
    }
}

@end
