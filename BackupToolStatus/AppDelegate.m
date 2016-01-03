//
//  AppDelegate.m
//  BackupToolStatus
//
//  Created by John Jones on 1/3/16.
//  Copyright © 2016 John Jones. All rights reserved.
//

#import "AppDelegate.h"
#import "BackupToolDatabase.h"

@interface AppDelegate () {
    NSStatusItem* _statusItem;
    BackupToolDatabase* _db;
    NSDictionary* _config;
}

- (void)_setupConfig;
- (void)_setupStatusItem;
- (void)_startPolling;
- (void)_pollingTimerFired:(NSTimer *)timer;

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self.window setDefaultButtonCell:self.applyButton.cell];
    [self _setupConfig];
    [self _setupStatusItem];
    [self _startPolling];
}

- (void)openPreferences:(id)sender {
    self.pathTextField.stringValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"configPath"];
    [self.window makeFirstResponder:nil];
    self.window.isVisible = true;
    [NSApp activateIgnoringOtherApps:YES];
}

#pragma mark - UI Methods

- (IBAction)browseButtonSelected:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = YES;
    panel.allowedFileTypes = @[@"json"];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        NSString* path = panel.URL.path;\
        if (path) {
            self.pathTextField.stringValue = path;
        }
    }];
}

- (IBAction)applyButtonSelected:(id)sender {
    NSString* newConfigPath = self.pathTextField.stringValue;
    if ([[NSFileManager defaultManager] fileExistsAtPath:newConfigPath]) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:newConfigPath forKey:@"configPath"];
        [defaults synchronize];
        [self _setupConfig];
        self.window.isVisible = false;
    } else {
        //TODO error
        NSLog(@"Error!");
    }
}

#pragma mark - Private

- (void)_setupConfig {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* configPathString = [defaults valueForKey:@"configPath"];
    if (!configPathString) {
        configPathString = [NSHomeDirectory() stringByAppendingPathComponent:@".backuptool.json"];
        [defaults setValue:configPathString forKey:@"configPath"];
        [defaults synchronize];
    }
    self.pathTextField.stringValue = configPathString;
    NSData* configContents = [[NSData alloc] initWithContentsOfFile:configPathString];
    if (configContents) {
        NSError* error;
        _config = [NSJSONSerialization JSONObjectWithData:configContents options:0 error:&error];
        if (error) {
            //TODO error
            NSLog(@"%@",error.localizedDescription);
        } else if (_config) {
            NSString* dbPath = [_config valueForKey:@"backupManifestFile"];
            if (dbPath) {
                _db = [[BackupToolDatabase alloc] initWithDatabasePath:dbPath];
            } else {
                //TODO error
            }
        } else {
            //TODO error
        }
    }
}

- (void)_setupStatusItem {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.button.image = [NSImage imageNamed:@"cloud"];
    _statusItem.button.imagePosition = NSImageLeft;
    
    NSMenu* menu = [[NSMenu alloc] init];
    [menu addItem:[[NSMenuItem alloc] initWithTitle:@"Preferences..." action:@selector(openPreferences:) keyEquivalent:@","]];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:[[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"]];
    _statusItem.menu = menu;
}

- (void)_startPolling {
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(_pollingTimerFired:) userInfo:nil repeats:YES];
    [self _pollingTimerFired:nil];
}

- (void)_pollingTimerFired:(NSTimer *)timer {
    float percent = _db.percentBackedUp;
    NSString* percentString = [NSString stringWithFormat:@"%.0f%%",percent * 100.0f];
    _statusItem.button.title = percentString;
}

@end
