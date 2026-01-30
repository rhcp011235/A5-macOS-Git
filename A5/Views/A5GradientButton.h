//
//  A5GradientButton.h
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//
//  Custom button with gradient background (Guna2GradientButton equivalent)
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface A5GradientButton : NSButton

@property (strong, nonatomic) NSColor *gradientColor1;
@property (strong, nonatomic) NSColor *gradientColor2;
@property (assign, nonatomic) CGFloat cornerRadius;
@property (assign, nonatomic) BOOL isEnabled;

@end

NS_ASSUME_NONNULL_END
