//
//  A5Constants.h
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface A5Constants : NSObject

// MARK: - Timing Constants
+ (NSTimeInterval)deviceCheckInterval;        // 3.0 seconds
+ (NSTimeInterval)processMonitorInterval;     // 2.0 seconds
+ (NSTimeInterval)deviceRestartWaitTime;      // 90.0 seconds

// MARK: - Color Constants
+ (NSColor *)backgroundColor;                  // RGB(30, 30, 32)
+ (NSColor *)accentColor;                      // RGB(255, 45, 85)
+ (NSColor *)textColor;                        // RGB(242, 242, 247)
+ (NSColor *)successColor;                     // Green
+ (NSColor *)warningColor;                     // Orange
+ (NSColor *)errorColor;                       // Red
+ (NSColor *)infoColor;                        // Blue

// MARK: - UI Constants
+ (CGSize)mainWindowSize;                      // 714x386
+ (CGFloat)buttonCornerRadius;                 // 8.0
+ (CGFloat)progressBarHeight;                  // 20.0

// MARK: - Path Constants
+ (NSString *)toolsDirectoryName;              // "Tools"
+ (NSString *)payloadsDirectoryName;           // "Payloads"
+ (NSString *)activationPayloadName;           // "A5"

// MARK: - Tool Names
+ (NSString *)ideviceIdTool;                   // "idevice_id"
+ (NSString *)ideviceinfoTool;                 // "ideviceinfo"
+ (NSString *)idevicediagnosticsTool;          // "idevicediagnostics"
+ (NSString *)afcclientTool;                   // "afcclient"
+ (NSString *)iproxyTool;                      // "iproxy"

// MARK: - Progress Percentages
+ (NSInteger)progressPayloadTransfer;          // 20
+ (NSInteger)progressFirstRestart;             // 60
+ (NSInteger)progressSecondRestart;            // 80
+ (NSInteger)progressComplete;                 // 100

@end

NS_ASSUME_NONNULL_END
