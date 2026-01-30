//
//  A5ProgressBar.m
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import "A5ProgressBar.h"
#import "A5Constants.h"

@implementation A5ProgressBar

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.wantsLayer = YES;

    _value = 0;
    _maximum = 100;
    _fillColor = [A5Constants accentColor];
    _backgroundColor = [NSColor colorWithWhite:0.2 alpha:1.0];
    _cornerRadius = 4.0;

    [self updateAppearance];
}

- (void)setValue:(NSInteger)value {
    _value = MIN(MAX(value, 0), self.maximum);
    [self setNeedsDisplay:YES];
}

- (void)setProgress:(NSInteger)value animated:(BOOL)animated {
    if (animated) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 0.3;
            [self setValue:value];
        } completionHandler:nil];
    } else {
        [self setValue:value];
    }
}

- (void)setFillColor:(NSColor *)fillColor {
    _fillColor = fillColor;
    [self setNeedsDisplay:YES];
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    [self setNeedsDisplay:YES];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self updateAppearance];
    [self setNeedsDisplay:YES];
}

- (void)updateAppearance {
    if (self.layer) {
        self.layer.cornerRadius = self.cornerRadius;
        self.layer.masksToBounds = YES;
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    // Draw background
    NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRoundedRect:self.bounds
                                                                   xRadius:self.cornerRadius
                                                                   yRadius:self.cornerRadius];
    [self.backgroundColor setFill];
    [backgroundPath fill];

    // Calculate progress width
    CGFloat progressWidth = (self.bounds.size.width * self.value) / (CGFloat)self.maximum;

    if (progressWidth > 0) {
        NSRect progressRect = NSMakeRect(0, 0, progressWidth, self.bounds.size.height);
        NSBezierPath *progressPath = [NSBezierPath bezierPathWithRoundedRect:progressRect
                                                                     xRadius:self.cornerRadius
                                                                     yRadius:self.cornerRadius];
        [self.fillColor setFill];
        [progressPath fill];
    }
}

@end
