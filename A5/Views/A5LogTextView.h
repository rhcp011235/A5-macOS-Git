//
//  A5LogTextView.h
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//
//  Color-coded log text view (Guna2TextBox equivalent)
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, A5LogLevel) {
    A5LogLevelDefault,
    A5LogLevelInfo,
    A5LogLevelSuccess,
    A5LogLevelWarning,
    A5LogLevelError
};

@interface A5LogTextView : NSScrollView

@property (strong, nonatomic, readonly) NSTextView *textView;

- (void)addLog:(NSString *)message level:(A5LogLevel)level;
- (void)addLog:(NSString *)message color:(NSColor *)color;
- (void)clearLogs;

@end

NS_ASSUME_NONNULL_END
