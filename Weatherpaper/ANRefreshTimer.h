//
//  ANRefreshTimer.h
//  Weatherpaper
//
//  Created by Alex Nichol on 1/3/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANAddressRequest.h"
#import "ANConditionRequest.h"

#define kForecastIOAppKey @"4eb14cb46a70c1a3ea0542ceaa7c36b3"

@protocol ANRefreshTimerDelegate

- (void)refreshTimerStarted:(id)sender;
- (void)refreshTimer:(id)sender gotState:(NSString *)state;
- (void)refreshTimer:(id)sender gotError:(NSError *)error;

@end

@interface ANRefreshTimer : NSObject <NSCoding, CLLocationManagerDelegate> {
    NSTimer * nextTick;
    NSDate * nextDate;
    NSTimeInterval refreshRate;
    
    CLLocationManager * manager;
    ANConditionRequest * cReq;
    ANAddressRequest * aReq;
}

@property (readwrite) NSTimeInterval refreshRate;
@property (nonatomic, weak) id<ANRefreshTimerDelegate> delegate;
@property (nonatomic, retain) NSString * address;

- (BOOL)isRunningNow;

- (NSString *)refreshRateTitle;
- (void)setRefreshRateWithTitle:(NSString *)title;

- (NSTimeInterval)timeRemaining;
- (NSString *)timeRemainingString;

- (void)trigger;

@end
