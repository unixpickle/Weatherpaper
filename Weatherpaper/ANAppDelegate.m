//
//  ANAppDelegate.m
//  Weatherpaper
//
//  Created by Alex Nichol on 1/3/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANAppDelegate.h"

@implementation ANAppDelegate

+ (NSString *)saveDirectory {
    NSString * appDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/Weatherpaper"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:appDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:appDir
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    }
    return appDir;
}

+ (NSString *)rulesSavePath {
    return [[self saveDirectory] stringByAppendingPathComponent:@"rules"];
}

+ (NSString *)timerSavePath {
    return [[self saveDirectory] stringByAppendingPathComponent:@"timer"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self.window setLevel:CGShieldingWindowLevel()];
    
    NSString * path = [ANAppDelegate rulesSavePath];
    rules = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (!rules) {
        rules = [ANConditionRules defaultConditions];
    }
    
    path = [ANAppDelegate timerSavePath];
    timer = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (!timer) {
        timer = [[ANRefreshTimer alloc] init];
    }
    timer.delegate = self;
    
    // load the UI
    locationCheckbox.state = timer.address == nil;
    locationText.stringValue = timer.address ?: @"";
    [locationText setEnabled:!locationCheckbox.state];
    [frequencyPopup selectItemWithTitle:timer.refreshRateTitle];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"\xF0\x9F\x92\xA6"];
    [statusItem setHighlightMode:YES];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self
                                   selector:@selector(updateTimerMenuItem)
                                   userInfo:nil repeats:YES];
}

- (void)saveRules {
    [NSKeyedArchiver archiveRootObject:rules toFile:[ANAppDelegate rulesSavePath]];
}
            
- (void)saveTimer {
    [NSKeyedArchiver archiveRootObject:timer toFile:[ANAppDelegate timerSavePath]];
}

- (void)setPath:(NSString *)path forQueueIndex:(NSInteger)row {
    if ([rules.queues[row] isKindOfClass:[ANImageDirectoryQueue class]]) {
        [rules.queues[row] setBaseDirectory:path];
        [rules.queues[row] reloadDirectory];
        return;
    }
    ANImageDirectoryQueue * queue = [[ANImageDirectoryQueue alloc] init];
    queue.baseDirectory = path;
    rules.queues[row] = queue;
}

- (IBAction)showPreferences:(id)sender {
    [self.window makeKeyAndOrderFront:nil];
}

- (IBAction)refreshWallpaper:(id)sender {
    [timer trigger];
}

- (IBAction)popupChanged:(id)sender {
    // change the refresh timer
    [timer setRefreshRateWithTitle:frequencyPopup.titleOfSelectedItem];
    [self saveTimer];
}

- (IBAction)locationCheckboxChanged:(id)sender {
    if (locationCheckbox.state) {
        timer.address = nil;
        [locationText setEnabled:NO];
    } else {
        timer.address = locationText.stringValue;
        [locationText setEnabled:YES];
    }
    [self saveTimer];
}

- (IBAction)locationTextboxChanged:(id)sender {
    timer.address = locationText.stringValue;
    [self saveTimer];
}

- (IBAction)updateWallpaper:(id)sender {
    id<ANGeneralImageQueue> queue = [rules queueForCondition:currentStateValue];
    if (!queue) {
        NSString * title = [NSString stringWithFormat:@"No path for %@", currentStateValue];
        return [refreshStatusItem setTitle:title];
    }
    for (NSScreen * s in [NSScreen screens]) {
        NSString * path = [queue popPath];
        [[NSWorkspace sharedWorkspace] setDesktopImageURL:[NSURL fileURLWithPath:path]
                                                forScreen:s
                                                  options:nil
                                                    error:nil];
    }
}

#pragma mark - Table View -

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return rules.conditions.count;
}

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([[tableColumn identifier] isEqualToString:@"enabled"]) {
        NSButtonCell * cell = [[NSButtonCell alloc] init];
        [cell setButtonType:NSSwitchButton];
        [cell setTitle:@""];
        return cell;
    }
    return nil;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // enabled, state, directory
    if ([tableColumn.identifier isEqualToString:@"enabled"]) {
        return @(![rules.queues[row] isKindOfClass:[ANVoidQueue class]]);
    } else if ([tableColumn.identifier isEqualToString:@"state"]) {
        return rules.conditions[row];
    } else if ([tableColumn.identifier isEqualToString:@"directory"]) {
        return [rules.queues[row] queueSourceString];
    }
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:@"enabled"]) {
        BOOL value = [object boolValue];
        if (value) {
            NSOpenPanel * openDlg = [NSOpenPanel openPanel];
            [openDlg setCanChooseFiles:NO];
            [openDlg setAllowsMultipleSelection:NO];
            [openDlg setCanChooseDirectories:YES];
            [openDlg beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
                if (result != NSOKButton) return;
                [self setPath:openDlg.URL.path forQueueIndex:row];
                [self saveRules];
            }];
        } else {
            rules.queues[row] = [[ANVoidQueue alloc] init];
            [self saveRules];
        }
    } else if ([tableColumn.identifier isEqualToString:@"directory"]) {
        [self setPath:object forQueueIndex:row];
        [self saveRules];
    }
}

#pragma mark - Refresh Timer -

- (void)refreshTimerStarted:(id)sender {
    [self updateTimerMenuItem];
}

- (void)refreshTimer:(id)sender gotState:(NSString *)state {
    currentState.stringValue = [NSString stringWithFormat:@"Current state: %@", state];
    currentStateValue = state;
    NSDateFormatter * format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy HH:mm"];
    NSString * str = [format stringFromDate:[NSDate date]];
    [refreshStatusItem setTitle:[NSString stringWithFormat:@"Last update at %@", str]];
    [self updateWallpaper:nil];
}

- (void)refreshTimer:(id)sender gotError:(NSError *)error {
    [refreshStatusItem setTitle:[NSString stringWithFormat:@"Last update failed"]];
}

- (void)updateTimerMenuItem {
    if (timer.isRunningNow) {
        refreshItem.action = nil;
        refreshItem.title = @"Refreshing now...";
    } else {
        refreshItem.action = @selector(refreshWallpaper:);
        refreshItem.title = [NSString stringWithFormat:@"Refresh (next in %@)", timer.timeRemainingString];
    }
}

@end
