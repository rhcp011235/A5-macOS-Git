//
//  A5ProgressBar.h
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//
//  Custom progress bar (Guna2ProgressBar equivalent)
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface A5ProgressBar : NSView

@property (assign, nonatomic) NSInteger value;  // 0-100
@property (assign, nonatomic) NSInteger maximum;  // Default 100
@property (strong, nonatomic) NSColor *fillColor;
@property (strong, nonatomic) NSColor *backgroundColor;
@property (assign, nonatomic) CGFloat cornerRadius;

- (void)setProgress:(NSInteger)value animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
