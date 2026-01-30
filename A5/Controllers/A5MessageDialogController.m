//
//  A5MessageDialogController.m
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import "A5MessageDialogController.h"
#import "A5Constants.h"

@implementation A5MessageDialogController

+ (void)showDialogWithTitle:(NSString *)title message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Use NSAlert for simplicity (can be replaced with custom XIB later)
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = title ?: @"A5";
        alert.informativeText = message ?: @"";
        alert.alertStyle = NSAlertStyleInformational;
        [alert addButtonWithTitle:@"OK"];

        // Customize appearance
        if (@available(macOS 10.14, *)) {
            alert.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
        }

        [alert runModal];
    });
}

- (void)windowDidLoad {
    [super windowDidLoad];

    // Setup borderless window with blur
    NSWindow *window = self.window;
    window.styleMask = NSWindowStyleMaskBorderless;
    window.backgroundColor = [A5Constants backgroundColor];
    window.titlebarAppearsTransparent = YES;
    window.movableByWindowBackground = YES;

    if (@available(macOS 10.14, *)) {
        window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
    }

    // Add blur effect
    NSVisualEffectView *blurView = [[NSVisualEffectView alloc] initWithFrame:window.contentView.bounds];
    blurView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    blurView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    blurView.state = NSVisualEffectStateActive;
    blurView.material = NSVisualEffectMaterialDark;

    [window.contentView addSubview:blurView positioned:NSWindowBelow relativeTo:nil];

    [window center];
}

- (IBAction)okButtonClicked:(id)sender {
    [self.window close];
}

@end
