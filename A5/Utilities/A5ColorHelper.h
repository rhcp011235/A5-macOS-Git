//
//  A5ColorHelper.h
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface A5ColorHelper : NSObject

+ (NSColor *)colorFromHex:(NSString *)hexString;
+ (NSColor *)colorFromRGB:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
+ (NSColor *)colorFromRGB:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
