//
//  A5Constants.m
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import "A5Constants.h"

@implementation A5Constants

// MARK: - Timing Constants
+ (NSTimeInterval)deviceCheckInterval {
    return 3.0;
}

+ (NSTimeInterval)processMonitorInterval {
    return 2.0;
}

+ (NSTimeInterval)deviceRestartWaitTime {
    return 90.0;
}

// MARK: - Color Constants
+ (NSColor *)backgroundColor {
    return [NSColor colorWithCalibratedRed:30.0/255.0 green:30.0/255.0 blue:32.0/255.0 alpha:1.0];
}

+ (NSColor *)accentColor {
    return [NSColor colorWithCalibratedRed:255.0/255.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
}

+ (NSColor *)textColor {
    return [NSColor colorWithCalibratedRed:242.0/255.0 green:242.0/255.0 blue:247.0/255.0 alpha:1.0];
}

+ (NSColor *)successColor {
    return [NSColor colorWithCalibratedRed:52.0/255.0 green:199.0/255.0 blue:89.0/255.0 alpha:1.0];
}

+ (NSColor *)warningColor {
    return [NSColor colorWithCalibratedRed:255.0/255.0 green:149.0/255.0 blue:0.0/255.0 alpha:1.0];
}

+ (NSColor *)errorColor {
    return [NSColor colorWithCalibratedRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0];
}

+ (NSColor *)infoColor {
    return [NSColor colorWithCalibratedRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
}

// MARK: - UI Constants
+ (CGSize)mainWindowSize {
    return CGSizeMake(750, 600);
}

+ (CGFloat)buttonCornerRadius {
    return 8.0;
}

+ (CGFloat)progressBarHeight {
    return 20.0;
}

// MARK: - Path Constants
+ (NSString *)toolsDirectoryName {
    return @"Tools";
}

+ (NSString *)payloadsDirectoryName {
    return @"Payloads";
}

+ (NSString *)activationPayloadName {
    return @"A5";
}

// MARK: - Tool Names
+ (NSString *)ideviceIdTool {
    return @"idevice_id";
}

+ (NSString *)ideviceinfoTool {
    return @"ideviceinfo";
}

+ (NSString *)idevicediagnosticsTool {
    return @"idevicediagnostics";
}

+ (NSString *)afcclientTool {
    return @"afcclient";
}

// MARK: - Progress Percentages
+ (NSInteger)progressPayloadTransfer {
    return 20;
}

+ (NSInteger)progressFirstRestart {
    return 60;
}

+ (NSInteger)progressSecondRestart {
    return 80;
}

+ (NSInteger)progressComplete {
    return 100;
}

@end
