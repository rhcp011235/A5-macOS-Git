//
//  AppDelegate.m
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import "AppDelegate.h"
#import "A5MainWindowController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Check for another instance (single-instance enforcement)
    if ([self isAnotherInstanceRunning]) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"A5 Already Running";
        alert.informativeText = @"Another instance of A5 is already running.";
        alert.alertStyle = NSAlertStyleWarning;
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];

        [NSApp terminate:nil];
        return;
    }

    // Launch main window (programmatic - no XIB)
    self.mainWindowController = [[A5MainWindowController alloc] init];
    [self.mainWindowController showWindow:nil];
    [self.mainWindowController.window makeKeyAndOrderFront:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Cleanup
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

#pragma mark - Single Instance Check

- (BOOL)isAnotherInstanceRunning {
    NSArray *runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];

    // Count should be 1 (current instance)
    // If more than 1, another instance is running
    return runningApps.count > 1;
}

@end
