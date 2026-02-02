//
//  A5MainWindowController.m
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import "A5MainWindowController.h"
#import "A5DeviceData.h"
#import "A5DeviceModelMapper.h"
#import "A5Constants.h"
#import "A5MessageDialogController.h"

@interface A5MainWindowController ()

@property (strong, nonatomic) A5DeviceData *currentDevice;

@end

@implementation A5MainWindowController

- (instancetype)init {
    // Create window programmatically with proper size
    CGSize windowSize = [A5Constants mainWindowSize];
    NSRect windowRect = NSMakeRect(0, 0, windowSize.width, windowSize.height);
    NSWindow *window = [[NSWindow alloc] initWithContentRect:windowRect
                                                   styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];

    window.title = @"A5 Activation Tool By RHCP011235";
    window.minSize = NSMakeSize(600, 400);

    self = [super initWithWindow:window];
    if (self) {
        [self createUI];

        // Since we're not using XIB, windowDidLoad won't be called
        // So we need to do setup here
        [self performInitialSetup];
    }
    return self;
}

- (void)performInitialSetup {
    [self setupWindow];
    [self setupServices];
    [self setupUI];

    [self addLog:@"A5 Activation Tool By RHCP011235 started" level:A5LogLevelInfo];
    [self addLog:@"This tool ONLY works with A5 chip devices:" level:A5LogLevelWarning];
    [self addLog:@"  • iPhone 4S, iPhone 5/5c" level:A5LogLevelWarning];
    [self addLog:@"  • iPad 2, iPad Mini 1st gen" level:A5LogLevelWarning];

    // Check if tools are available
    NSString *toolPath = [[NSBundle mainBundle] pathForResource:@"idevice_id" ofType:nil inDirectory:@"Tools"];
    if (toolPath) {
        [self addLog:[NSString stringWithFormat:@"Found idevice_id at: %@", toolPath] level:A5LogLevelInfo];
    } else {
        [self addLog:@"WARNING: idevice_id not found in bundle!" level:A5LogLevelWarning];
    }

    // Start monitoring
    [self.deviceManager startMonitoring];
    // Process monitor disabled for debugging (was spamming logs)
    // [self.processMonitor startMonitoring];

    [self addLog:@"Device monitoring started (checking every 3 seconds)" level:A5LogLevelInfo];
    [self addLog:@"WARNING: Process monitor DISABLED (debug mode - no anti-debug protection)" level:A5LogLevelWarning];
    [self addLog:@"Waiting for device connection..." level:A5LogLevelDefault];

    // Do an immediate device check
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addLog:@"Running initial device check..." level:A5LogLevelInfo];
        [self.deviceManager checkForDevices];
    });
}

- (void)windowDidLoad {
    [super windowDidLoad];

    [self setupWindow];
    [self setupServices];
    [self setupUI];

    [self addLog:@"A5 Activation Tool By RHCP011235 started" level:A5LogLevelInfo];
    [self addLog:@"This tool ONLY works with A5 chip devices:" level:A5LogLevelWarning];
    [self addLog:@"  • iPhone 4S, iPhone 5/5c" level:A5LogLevelWarning];
    [self addLog:@"  • iPad 2, iPad Mini 1st gen" level:A5LogLevelWarning];

    // Check if tools are available
    NSString *toolPath = [[NSBundle mainBundle] pathForResource:@"idevice_id" ofType:nil inDirectory:@"Tools"];
    if (toolPath) {
        [self addLog:[NSString stringWithFormat:@"Found idevice_id at: %@", toolPath] level:A5LogLevelInfo];
    } else {
        [self addLog:@"WARNING: idevice_id not found in bundle!" level:A5LogLevelWarning];
    }

    // Start monitoring
    [self.deviceManager startMonitoring];
    // Process monitor disabled for debugging (was spamming logs)
    // [self.processMonitor startMonitoring];

    [self addLog:@"Device monitoring started (checking every 3 seconds)" level:A5LogLevelInfo];
    [self addLog:@"WARNING: Process monitor DISABLED (debug mode - no anti-debug protection)" level:A5LogLevelWarning];
    [self addLog:@"Waiting for device connection..." level:A5LogLevelDefault];

    // Do an immediate device check
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.deviceManager checkForDevices];
    });
}

- (void)createUI {
    NSWindow *window = self.window;
    NSView *contentView = window.contentView;

    // Set window background color
    window.backgroundColor = [A5Constants backgroundColor];

    // Create all UI components programmatically
    CGFloat margin = 20;
    CGFloat currentY = contentView.bounds.size.height - margin - 20; // Start from top

    // Title label
    NSTextField *titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(margin, currentY, 400, 26)];
    titleLabel.stringValue = @"A5 Activation Tool By RHCP011235";
    titleLabel.editable = NO;
    titleLabel.bordered = NO;
    titleLabel.backgroundColor = [NSColor clearColor];
    titleLabel.textColor = [A5Constants textColor];
    titleLabel.font = [NSFont boldSystemFontOfSize:20];
    [contentView addSubview:titleLabel];

    currentY -= 40;

    // Status label
    self.statusLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(margin, currentY, 400, 22)];
    self.statusLabel.stringValue = @"No Device Connected";
    self.statusLabel.editable = NO;
    self.statusLabel.bordered = NO;
    self.statusLabel.backgroundColor = [NSColor clearColor];
    self.statusLabel.textColor = [A5Constants warningColor];
    self.statusLabel.font = [NSFont systemFontOfSize:15];
    [contentView addSubview:self.statusLabel];

    currentY -= 35;

    // Device info labels
    CGFloat labelWidth = 140;
    CGFloat valueX = margin + labelWidth + 10;

    NSTextField *modelTitle = [self createLabel:@"Model:" frame:NSMakeRect(margin, currentY, labelWidth, 18) bold:YES];
    [contentView addSubview:modelTitle];
    self.modelLabel = [self createLabel:@"Unknown Device" frame:NSMakeRect(valueX, currentY, 500, 18) bold:NO];
    [contentView addSubview:self.modelLabel];
    currentY -= 24;

    NSTextField *iosTitle = [self createLabel:@"iOS Version:" frame:NSMakeRect(margin, currentY, labelWidth, 18) bold:YES];
    [contentView addSubview:iosTitle];
    self.iosVersionLabel = [self createLabel:@"N/A" frame:NSMakeRect(valueX, currentY, 500, 18) bold:NO];
    [contentView addSubview:self.iosVersionLabel];
    currentY -= 24;

    NSTextField *serialTitle = [self createLabel:@"Serial:" frame:NSMakeRect(margin, currentY, labelWidth, 18) bold:YES];
    [contentView addSubview:serialTitle];
    self.serialLabel = [self createLabel:@"N/A" frame:NSMakeRect(valueX, currentY, 500, 18) bold:NO];
    [contentView addSubview:self.serialLabel];
    currentY -= 24;

    NSTextField *imeiTitle = [self createLabel:@"IMEI:" frame:NSMakeRect(margin, currentY, labelWidth, 18) bold:YES];
    [contentView addSubview:imeiTitle];
    self.imeiLabel = [self createLabel:@"N/A" frame:NSMakeRect(valueX, currentY, 500, 18) bold:NO];
    [contentView addSubview:self.imeiLabel];
    currentY -= 24;

    NSTextField *ecidTitle = [self createLabel:@"ECID:" frame:NSMakeRect(margin, currentY, labelWidth, 18) bold:YES];
    [contentView addSubview:ecidTitle];
    self.ecidLabel = [self createLabel:@"N/A" frame:NSMakeRect(valueX, currentY, 500, 18) bold:NO];
    [contentView addSubview:self.ecidLabel];
    currentY -= 24;

    NSTextField *activationTitle = [self createLabel:@"Activation Status:" frame:NSMakeRect(margin, currentY, labelWidth, 18) bold:YES];
    [contentView addSubview:activationTitle];
    self.activationStatusLabel = [self createLabel:@"N/A" frame:NSMakeRect(valueX, currentY, 500, 18) bold:NO];
    [contentView addSubview:self.activationStatusLabel];
    currentY -= 40;

    // Progress bar
    self.progressBar = [[A5ProgressBar alloc] initWithFrame:NSMakeRect(margin, currentY, contentView.bounds.size.width - 2*margin, 22)];
    self.progressBar.value = 0;
    self.progressBar.fillColor = [A5Constants accentColor];
    [contentView addSubview:self.progressBar];
    currentY -= 28;

    // Progress label
    self.progressLabel = [self createLabel:@"" frame:NSMakeRect(margin, currentY, contentView.bounds.size.width - 2*margin, 18) bold:NO];
    self.progressLabel.alignment = NSTextAlignmentCenter;
    [contentView addSubview:self.progressLabel];
    currentY -= 35;

    // Backend selector (dropdown)
    NSTextField *backendLabel = [self createLabel:@"Backend Server:" frame:NSMakeRect(margin, currentY + 2, 120, 18) bold:NO];
    [contentView addSubview:backendLabel];

    self.backendSelector = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(margin + 130, currentY, 150, 26) pullsDown:NO];
    [self.backendSelector addItemWithTitle:@"Remote (Online)"];
    [self.backendSelector addItemWithTitle:@"Local (Experimental)"];
    [self.backendSelector selectItemAtIndex:0]; // Default to Remote (works 100%)
    self.useLocalBackend = NO;
    self.backendSelector.target = self;
    self.backendSelector.action = @selector(backendSelectorChanged:);
    [contentView addSubview:self.backendSelector];
    currentY -= 45; // More spacing before activate button

    // Activate button
    self.activateButton = [[A5GradientButton alloc] initWithFrame:NSMakeRect(margin, currentY, 220, 44)];
    self.activateButton.title = @"Activate Your Device";
    self.activateButton.target = self;
    self.activateButton.action = @selector(activateButtonClicked:);
    self.activateButton.isEnabled = NO;
    [contentView addSubview:self.activateButton];
    currentY -= 60;

    // Log label and verbose checkbox (side by side)
    NSTextField *logLabel = [self createLabel:@"Log:" frame:NSMakeRect(margin, currentY, 50, 18) bold:YES];
    [contentView addSubview:logLabel];

    self.verboseLoggingCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(margin + 60, currentY - 2, 150, 22)];
    [self.verboseLoggingCheckbox setButtonType:NSButtonTypeSwitch];
    self.verboseLoggingCheckbox.title = @"Verbose Logging";
    self.verboseLoggingCheckbox.target = self;
    self.verboseLoggingCheckbox.action = @selector(verboseLoggingToggled:);
    self.verboseLoggingCheckbox.state = NSControlStateValueOn; // Default to ON
    self.verboseLogging = YES;
    [contentView addSubview:self.verboseLoggingCheckbox];

    currentY -= 25;

    // Log text view (A5LogTextView is already a scroll view, don't wrap it!)
    CGFloat logHeight = currentY - margin;
    if (logHeight < 100) logHeight = 100;

    self.logTextView = [[A5LogTextView alloc] initWithFrame:NSMakeRect(margin, margin, contentView.bounds.size.width - 2*margin, logHeight)];
    [contentView addSubview:self.logTextView];
}

- (NSTextField *)createLabel:(NSString *)text frame:(NSRect)frame bold:(BOOL)bold {
    NSTextField *label = [[NSTextField alloc] initWithFrame:frame];
    label.stringValue = text;
    label.editable = NO;
    label.bordered = NO;
    label.drawsBackground = NO;
    label.backgroundColor = [NSColor clearColor];
    label.textColor = [A5Constants textColor];
    if (bold) {
        label.font = [NSFont boldSystemFontOfSize:12];
    } else {
        label.font = [NSFont systemFontOfSize:12];
    }
    return label;
}

- (void)dealloc {
    [self.deviceManager stopMonitoring];
    [self.processMonitor stopMonitoring];
}

#pragma mark - Setup

- (void)setupWindow {
    NSWindow *window = self.window;

    // Set window appearance
    window.backgroundColor = [A5Constants backgroundColor];

    // Enable dark mode
    if (@available(macOS 10.14, *)) {
        window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
    }

    // Center window
    [window center];
}

- (void)setupServices {
    // Device Manager
    self.deviceManager = [[A5DeviceManager alloc] init];
    self.deviceManager.delegate = self;

    // Process Monitor
    self.processMonitor = [[A5ProcessMonitor alloc] init];
    self.processMonitor.delegate = self;

    // Activation Service
    self.activationService = [[A5ActivationService alloc] init];
    self.activationService.delegate = self;
}

- (void)setupUI {
    self.isProcessRunning = NO;

    // Initial UI state
    [self updateUIForDisconnectedState];

    // Configure activate button
    if (self.activateButton) {
        self.activateButton.gradientColor1 = [A5Constants accentColor];
        self.activateButton.gradientColor2 = [A5Constants accentColor];
        self.activateButton.cornerRadius = [A5Constants buttonCornerRadius];
        self.activateButton.title = @"Activate Your Device";
        self.activateButton.isEnabled = NO;
    }

    // Configure progress bar
    if (self.progressBar) {
        self.progressBar.value = 0;
        self.progressBar.fillColor = [A5Constants accentColor];
    }
}

#pragma mark - UI Updates

- (void)updateUIForDisconnectedState {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.statusLabel) {
            self.statusLabel.stringValue = @"No Device Connected";
            self.statusLabel.textColor = [A5Constants warningColor];
        }

        if (self.modelLabel) self.modelLabel.stringValue = @"Unknown Device";
        if (self.iosVersionLabel) self.iosVersionLabel.stringValue = @"N/A";
        if (self.serialLabel) self.serialLabel.stringValue = @"N/A";
        if (self.imeiLabel) self.imeiLabel.stringValue = @"N/A";
        if (self.ecidLabel) self.ecidLabel.stringValue = @"N/A";
        if (self.activationStatusLabel) self.activationStatusLabel.stringValue = @"N/A";

        if (self.activateButton) {
            self.activateButton.isEnabled = NO;
        }

        if (self.progressBar) {
            self.progressBar.value = 0;
        }

        if (self.progressLabel) {
            self.progressLabel.stringValue = @"";
        }
    });
}

- (void)updateUIForConnectedDevice:(A5DeviceData *)deviceData {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentDevice = deviceData;

        if (self.statusLabel) {
            self.statusLabel.stringValue = @"Device Connected";
            self.statusLabel.textColor = [A5Constants successColor];
        }

        if (self.modelLabel) {
            self.modelLabel.stringValue = deviceData.modelName ?: @"Unknown Device";
        }

        if (self.iosVersionLabel) {
            self.iosVersionLabel.stringValue = deviceData.productVersion ?: @"N/A";
        }

        if (self.serialLabel) {
            self.serialLabel.stringValue = deviceData.serialNumber ?: @"N/A";
        }

        if (self.imeiLabel) {
            self.imeiLabel.stringValue = deviceData.imei ?: @"N/A";
        }

        if (self.ecidLabel) {
            self.ecidLabel.stringValue = deviceData.ecid ?: @"N/A";
        }

        if (self.activationStatusLabel) {
            self.activationStatusLabel.stringValue = deviceData.activationState ?: @"Unactivated";
        }

        // Check if device is A5 chip
        if ([A5DeviceModelMapper isA5Device:deviceData.productType]) {
            [self addLog:[NSString stringWithFormat:@"Device is supported: %@", deviceData.modelName] level:A5LogLevelSuccess];

            if (self.activateButton && !self.isProcessRunning) {
                self.activateButton.isEnabled = YES;
            }

            if (self.progressBar) {
                self.progressBar.value = 100;
            }

            if (self.progressLabel) {
                self.progressLabel.stringValue = @"Congratulations your device is supported!";
            }

            // Show support dialog
            [A5MessageDialogController showDialogWithTitle:@"A5"
                                                   message:@"Congratulations your device is supported for A5 Activation. MAKE SURE YOU CONNECTED TO WIFI ON DEVICE. Click the button 'Activate Your Device' to activate your device"];
        } else {
            [self addLog:[NSString stringWithFormat:@"Device not supported: %@ (%@)", deviceData.modelName, deviceData.productType] level:A5LogLevelWarning];

            if (self.activateButton) {
                self.activateButton.isEnabled = NO;
            }

            if (self.progressLabel) {
                self.progressLabel.stringValue = @"This device is not supported";
            }

            [A5MessageDialogController showDialogWithTitle:@"Not Supported"
                                                   message:[NSString stringWithFormat:@"Your device (%@) is not supported for A5 activation. This tool only supports A5 chip devices (iPhone 4S, iPhone 5/5c, iPad 2).", deviceData.modelName]];
        }
    });
}

- (void)updateProgress:(NSInteger)percentage message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progressBar) {
            [self.progressBar setProgress:percentage animated:YES];
        }

        if (self.progressLabel) {
            self.progressLabel.stringValue = message ?: @"";
        }
    });
}

#pragma mark - A5DeviceManagerDelegate

- (void)deviceConnected:(A5DeviceData *)deviceData {
    [self addLog:[NSString stringWithFormat:@"Device connected: %@", deviceData.udid] level:A5LogLevelSuccess];
    [self addLog:[NSString stringWithFormat:@"Model: %@", deviceData.modelName] level:A5LogLevelInfo];
    [self addLog:[NSString stringWithFormat:@"iOS: %@", deviceData.productVersion] level:A5LogLevelInfo];

    [self updateUIForConnectedDevice:deviceData];
}

- (void)deviceDisconnected {
    [self addLog:@"Device disconnected" level:A5LogLevelWarning];
    [self updateUIForDisconnectedState];
    self.currentDevice = nil;
}

- (void)deviceInfoUpdated:(A5DeviceData *)deviceData {
    // Silently update device info
    self.currentDevice = deviceData;
}

#pragma mark - A5ProcessMonitorDelegate

- (void)processKilled:(NSString *)processName pid:(pid_t)pid {
    // Process was killed by monitor
}

- (void)processMonitorLogMessage:(NSString *)message {
    [self addLog:message level:A5LogLevelWarning];
}

#pragma mark - A5ActivationServiceDelegate

- (void)activationProgressUpdated:(NSInteger)percentage message:(NSString *)message {
    [self updateProgress:percentage message:message];
    [self addLog:message level:A5LogLevelInfo];
}

- (void)activationCompleted:(BOOL)success message:(NSString *)message {
    self.isProcessRunning = NO;

    if (self.activateButton) {
        self.activateButton.isEnabled = YES;
        self.activateButton.title = @"Activate Your Device";
    }

    if (success) {
        [self addLog:@"Activation successful!" level:A5LogLevelSuccess];
        [self updateProgress:100 message:@"Activation completed!"];

        [A5MessageDialogController showDialogWithTitle:@"Success" message:message];

        // Refresh device info
        if (self.currentDevice && self.currentDevice.udid) {
            [self.deviceManager getDeviceInfo:self.currentDevice.udid completion:^(A5DeviceData *deviceData, NSError *error) {
                if (deviceData) {
                    [self updateUIForConnectedDevice:deviceData];
                }
            }];
        }
    } else {
        [self addLog:[@"ERROR: " stringByAppendingString:message] level:A5LogLevelError];
        [self updateProgress:0 message:message];

        [A5MessageDialogController showDialogWithTitle:@"Activation Failed" message:message];
    }
}

- (void)activationLogMessage:(NSString *)message {
    // Filter verbose messages if verbose logging is disabled
    if (!self.verboseLogging) {
        // Skip verbose debug messages
        if ([message containsString:@"[Backend]"] ||
            [message containsString:@"MobileGestalt output for"] ||
            [message containsString:@"stdout:"] ||
            [message containsString:@"Executing:"] ||
            [message containsString:@"command output:"] ||
            [message containsString:@"Checking MobileGestalt key:"] ||
            [message containsString:@"→ Checking"] ||
            [message containsString:@"Transferring payload via AFC to"] ||
            [message containsString:@"  "] || // Indented verbose output
            [message hasPrefix:@"<?xml"] || // XML output
            [message hasPrefix:@"<plist"] ||
            [message hasPrefix:@"<dict"] ||
            [message hasPrefix:@"<key"] ||
            [message containsString:@"<!DOCTYPE"]) {
            return; // Skip verbose message
        }
    }

    [self addLog:message level:A5LogLevelInfo];
}

- (IBAction)verboseLoggingToggled:(id)sender {
    self.verboseLogging = (self.verboseLoggingCheckbox.state == NSControlStateValueOn);
    NSString *status = self.verboseLogging ? @"enabled" : @"disabled";
    [self addLog:[NSString stringWithFormat:@"Verbose logging %@", status] level:A5LogLevelInfo];
}

- (IBAction)backendSelectorChanged:(id)sender {
    self.useLocalBackend = (self.backendSelector.indexOfSelectedItem == 1); // Index 1 is Local
    NSString *backend = self.useLocalBackend ? @"Local (Experimental)" : @"Remote (Online)";
    [self addLog:[NSString stringWithFormat:@"Backend server set to: %@", backend] level:A5LogLevelInfo];

    if (self.useLocalBackend) {
        [self addLog:@"⚠️ WARNING: Local backend is experimental and may not work" level:A5LogLevelWarning];
        [self addLog:@"⚠️ Known issue: Device may not connect to localhost through USB tunnel" level:A5LogLevelWarning];
        [self addLog:@"💡 Recommended: Use Remote backend for guaranteed success" level:A5LogLevelInfo];
    } else {
        [self addLog:@"ℹ️ Remote backend requires device to have WiFi + internet access" level:A5LogLevelInfo];
    }
}

#pragma mark - Actions

- (IBAction)activateButtonClicked:(id)sender {
    if (self.isProcessRunning) {
        return;
    }

    if (!self.currentDevice || !self.currentDevice.udid) {
        [A5MessageDialogController showDialogWithTitle:@"No Device"
                                               message:@"There is no device connected. Please connect your device using USB cable."];
        return;
    }

    // Check if device is A5
    if (![A5DeviceModelMapper isA5Device:self.currentDevice.productType]) {
        [A5MessageDialogController showDialogWithTitle:@"Not Supported"
                                               message:@"This device is not supported for A5 activation."];
        return;
    }

    self.isProcessRunning = YES;

    if (self.activateButton) {
        self.activateButton.title = @"Processing...";
        self.activateButton.isEnabled = NO;
    }

    [self addLog:@"Starting activation process..." level:A5LogLevelInfo];

    // Configure backend setting
    self.activationService.useLocalBackend = self.useLocalBackend;

    // Start activation
    [self.activationService activateDevice:self.currentDevice.udid];
}

- (IBAction)closeButtonClicked:(id)sender {
    [self.deviceManager stopMonitoring];
    [self.processMonitor stopMonitoring];
    [[NSApplication sharedApplication] terminate:nil];
}

- (IBAction)minimizeButtonClicked:(id)sender {
    [self.window miniaturize:nil];
}

#pragma mark - Logging

- (void)addLog:(NSString *)message level:(A5LogLevel)level {
    if (self.logTextView) {
        [self.logTextView addLog:message level:level];
    }
}

@end
