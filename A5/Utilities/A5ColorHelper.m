//
//  A5ColorHelper.m
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import "A5ColorHelper.h"

@implementation A5ColorHelper

+ (NSColor *)colorFromHex:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if ([cleanString length] == 6) {
        unsigned int red, green, blue;
        NSScanner *rScanner = [NSScanner scannerWithString:[cleanString substringWithRange:NSMakeRange(0, 2)]];
        NSScanner *gScanner = [NSScanner scannerWithString:[cleanString substringWithRange:NSMakeRange(2, 2)]];
        NSScanner *bScanner = [NSScanner scannerWithString:[cleanString substringWithRange:NSMakeRange(4, 2)]];
        [rScanner scanHexInt:&red];
        [gScanner scanHexInt:&green];
        [bScanner scanHexInt:&blue];
        return [self colorFromRGB:red green:green blue:blue];
    }
    return [NSColor blackColor];
}

+ (NSColor *)colorFromRGB:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    return [self colorFromRGB:red green:green blue:blue alpha:1.0];
}

+ (NSColor *)colorFromRGB:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    return [NSColor colorWithCalibratedRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

@end
