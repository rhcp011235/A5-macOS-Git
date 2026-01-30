//
//  A5GradientButton.m
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import "A5GradientButton.h"
#import "A5Constants.h"

@implementation A5GradientButton

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
    self.bordered = NO;
    self.bezelStyle = NSBezelStyleRegularSquare;

    _gradientColor1 = [A5Constants accentColor];
    _gradientColor2 = [A5Constants accentColor];
    _cornerRadius = [A5Constants buttonCornerRadius];
    _isEnabled = YES;

    [self updateAppearance];
}

- (void)setGradientColor1:(NSColor *)gradientColor1 {
    _gradientColor1 = gradientColor1;
    [self setNeedsDisplay:YES];
}

- (void)setGradientColor2:(NSColor *)gradientColor2 {
    _gradientColor2 = gradientColor2;
    [self setNeedsDisplay:YES];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self updateAppearance];
    [self setNeedsDisplay:YES];
}

- (void)setIsEnabled:(BOOL)isEnabled {
    _isEnabled = isEnabled;
    self.enabled = isEnabled;
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

    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];

    // Create rounded rectangle path
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:self.bounds
                                                         xRadius:self.cornerRadius
                                                         yRadius:self.cornerRadius];

    // Create gradient
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:self.gradientColor1
                                                         endingColor:self.gradientColor2];

    // Draw gradient
    CGFloat angle = 45.0;  // Forward diagonal
    NSPoint startPoint = NSMakePoint(0, 0);
    NSPoint endPoint = NSMakePoint(self.bounds.size.width, self.bounds.size.height);

    [gradient drawInBezierPath:path angle:angle];

    // If disabled, draw overlay
    if (!self.isEnabled) {
        [[NSColor colorWithWhite:0.0 alpha:0.5] setFill];
        [path fill];
    }

    // Draw title
    NSDictionary *attributes = @{
        NSFontAttributeName: self.font ?: [NSFont systemFontOfSize:13],
        NSForegroundColorAttributeName: [A5Constants textColor]
    };

    NSString *title = self.title ?: @"";
    NSSize titleSize = [title sizeWithAttributes:attributes];

    NSPoint titlePoint = NSMakePoint(
        (self.bounds.size.width - titleSize.width) / 2.0,
        (self.bounds.size.height - titleSize.height) / 2.0
    );

    [title drawAtPoint:titlePoint withAttributes:attributes];

    [context restoreGraphicsState];
}

- (void)mouseDown:(NSEvent *)event {
    if (self.isEnabled) {
        [super mouseDown:event];
    }
}

@end
