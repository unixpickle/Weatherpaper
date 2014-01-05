//
//  ANAppDelegate.h
//  Weatherpaper
//
//  Created by Alex Nichol on 1/3/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANConditionRules.h"
#import "ANImageDirectoryQueue.h"
#import "ANRefreshTimer.h"

@interface ANAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, ANRefreshTimerDelegate> {
    IBOutlet NSMenu * statusMenu;
    IBOutlet NSMenuItem * refreshItem;
    IBOutlet NSMenuItem * refreshStatusItem;
    IBOutlet NSTableView * tableView;
    
    // in window options
    IBOutlet NSPopUpButton * frequencyPopup;
    IBOutlet NSButton * locationCheckbox;
    IBOutlet NSTextField * locationText;
    
    NSStatusItem * statusItem;
    ANConditionRules * rules;
    ANRefreshTimer * timer;
    
    IBOutlet NSTextField * currentState;
    NSString * currentStateValue;
}

@property (nonatomic, strong) IBOutlet NSWindow * window;

+ (NSString *)saveDirectory;
+ (NSString *)rulesSavePath;
+ (NSString *)timerSavePath;

- (void)receiveWakeNote:(NSNotification *)note;

- (void)saveRules;
- (void)saveTimer;
- (void)setPath:(NSString *)path forQueueIndex:(NSInteger)row;

- (IBAction)showPreferences:(id)sender;
- (IBAction)refreshWallpaper:(id)sender;
- (IBAction)popupChanged:(id)sender;
- (IBAction)locationCheckboxChanged:(id)sender;
- (IBAction)locationTextboxChanged:(id)sender;
- (IBAction)updateWallpaper:(id)sender;

- (void)updateTimerMenuItem;

@end
