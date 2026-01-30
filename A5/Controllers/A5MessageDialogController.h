//
//  A5MessageDialogController.h
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//
//  Message dialog (Form2 equivalent)
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface A5MessageDialogController : NSWindowController

@property (weak, nonatomic) IBOutlet NSTextField *titleLabel;
@property (weak, nonatomic) IBOutlet NSTextField *messageLabel;
@property (weak, nonatomic) IBOutlet NSButton *okButton;

/**
 * Show modal dialog with title and message
 */
+ (void)showDialogWithTitle:(NSString *)title message:(NSString *)message;

- (IBAction)okButtonClicked:(id)sender;

@end

NS_ASSUME_NONNULL_END
