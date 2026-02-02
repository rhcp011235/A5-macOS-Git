//
//  A5MainWindowController.h
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//
//  Main window controller (Form1 equivalent)
//

#import <Cocoa/Cocoa.h>
#import "A5DeviceManager.h"
#import "A5ProcessMonitor.h"
#import "A5ActivationService.h"
#import "A5GradientButton.h"
#import "A5ProgressBar.h"
#import "A5LogTextView.h"

NS_ASSUME_NONNULL_BEGIN

@interface A5MainWindowController : NSWindowController <A5DeviceManagerDelegate, A5ProcessMonitorDelegate, A5ActivationServiceDelegate>

// UI Components
@property (strong, nonatomic) NSImageView *deviceImageView;
@property (strong, nonatomic) NSTextField *modelLabel;
@property (strong, nonatomic) NSTextField *iosVersionLabel;
@property (strong, nonatomic) NSTextField *serialLabel;
@property (strong, nonatomic) NSTextField *imeiLabel;
@property (strong, nonatomic) NSTextField *ecidLabel;
@property (strong, nonatomic) NSTextField *activationStatusLabel;
@property (strong, nonatomic) NSTextField *statusLabel;
@property (strong, nonatomic) NSTextField *progressLabel;
@property (strong, nonatomic) A5ProgressBar *progressBar;
@property (strong, nonatomic) A5GradientButton *activateButton;
@property (strong, nonatomic) A5LogTextView *logTextView;
@property (strong, nonatomic) NSButton *verboseLoggingCheckbox;
@property (strong, nonatomic) NSPopUpButton *backendSelector;

// Services
@property (strong, nonatomic) A5DeviceManager *deviceManager;
@property (strong, nonatomic) A5ProcessMonitor *processMonitor;
@property (strong, nonatomic) A5ActivationService *activationService;

// State
@property (assign, nonatomic) BOOL isProcessRunning;
@property (assign, nonatomic) BOOL verboseLogging;
@property (assign, nonatomic) NSInteger backendServerType; // 0=nothingtool, 1=mrcellphone, 2=local

// Actions
- (IBAction)activateButtonClicked:(id)sender;
- (IBAction)closeButtonClicked:(id)sender;
- (IBAction)minimizeButtonClicked:(id)sender;
- (IBAction)verboseLoggingToggled:(id)sender;
- (IBAction)backendSelectorChanged:(id)sender;

@end

NS_ASSUME_NONNULL_END
