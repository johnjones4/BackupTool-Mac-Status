//
//  AppDelegate.h
//  BackupToolStatus
//
//  Created by John Jones on 1/3/16.
//  Copyright © 2016 John Jones. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSTextField *pathTextField;
@property (weak) IBOutlet NSLayoutConstraint *browseButton;
@property (weak) IBOutlet NSButton *applyButton;

- (IBAction)browseButtonSelected:(id)sender;
- (IBAction)applyButtonSelected:(id)sender;

@end

