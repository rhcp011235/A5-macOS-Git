//
//  A5LogTextView.m
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import "A5LogTextView.h"
#import "A5Constants.h"

@interface A5LogTextView ()

@property (strong, nonatomic, readwrite) NSTextView *textView;

@end

@implementation A5LogTextView

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
    // Create text view
    _textView = [[NSTextView alloc] initWithFrame:self.bounds];
    _textView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    _textView.editable = NO;
    _textView.selectable = YES;
    _textView.backgroundColor = [NSColor colorWithWhite:0.1 alpha:1.0];
    _textView.textColor = [A5Constants textColor];
    _textView.font = [NSFont fontWithName:@"Menlo" size:11] ?: [NSFont systemFontOfSize:11];

    // Configure scroll view
    self.documentView = _textView;
    self.hasVerticalScroller = YES;
    self.hasHorizontalScroller = NO;
    self.autohidesScrollers = YES;
    self.borderType = NSBezelBorder;
}

- (void)addLog:(NSString *)message level:(A5LogLevel)level {
    NSColor *color;

    switch (level) {
        case A5LogLevelInfo:
            color = [A5Constants infoColor];
            break;
        case A5LogLevelSuccess:
            color = [A5Constants successColor];
            break;
        case A5LogLevelWarning:
            color = [A5Constants warningColor];
            break;
        case A5LogLevelError:
            color = [A5Constants errorColor];
            break;
        default:
            color = [A5Constants textColor];
            break;
    }

    [self addLog:message color:color];
}

- (void)addLog:(NSString *)message color:(NSColor *)color {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Get current timestamp
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm:ss";
        NSString *timestamp = [formatter stringFromDate:[NSDate date]];

        // Create attributed string
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];

        // Timestamp in gray
        NSDictionary *timestampAttrs = @{
            NSForegroundColorAttributeName: [NSColor grayColor],
            NSFontAttributeName: self.textView.font
        };
        NSAttributedString *timestampString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@] ", timestamp]
                                                                               attributes:timestampAttrs];
        [attributedString appendAttributedString:timestampString];

        // Message in specified color
        NSDictionary *messageAttrs = @{
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: self.textView.font
        };
        NSAttributedString *messageString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", message]
                                                                             attributes:messageAttrs];
        [attributedString appendAttributedString:messageString];

        // Append to text view
        [self.textView.textStorage appendAttributedString:attributedString];

        // Auto-scroll to bottom
        [self.textView scrollRangeToVisible:NSMakeRange(self.textView.string.length, 0)];
    });
}

- (void)clearLogs {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.textView setString:@""];
    });
}

@end
