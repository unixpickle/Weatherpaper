//
//  ANRefreshTimer.m
//  Weatherpaper
//
//  Created by Alex Nichol on 1/3/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANRefreshTimer.h"

@interface ANRefreshTimer (Private)

+ (NSDictionary *)ratesDict;
- (void)beginNextInterval;
- (void)gotError:(NSError *)error;
- (void)gotLocation:(CLLocation *)loc;

@end

@implementation ANRefreshTimer

- (id)init {
    if ((self = [super init])) {
        self.refreshRate = 60*30;
    }
    return self;
}

- (BOOL)isRunningNow {
    return aReq || cReq || manager;
}

- (NSTimeInterval)refreshRate {
    return refreshRate;
}

- (void)setRefreshRate:(NSTimeInterval)rate {
    refreshRate = rate;
    if (self.isRunningNow) return;
    [self beginNextInterval];
}

- (NSString *)refreshRateTitle {
    NSDictionary * dict = [self.class ratesDict];
    for (NSString * key in dict) {
        if ([dict[key] isEqualToNumber:@(refreshRate)]) {
            return key;
        }
    }
    @throw [NSException exceptionWithName:@"NoTimerTitle" reason:@"No timer title found" userInfo:nil];
}

- (void)setRefreshRateWithTitle:(NSString *)title {
    self.refreshRate = [[self.class ratesDict][title] doubleValue];
}

- (NSTimeInterval)timeRemaining {
    return [nextDate timeIntervalSinceDate:[NSDate date]];
}

- (NSString *)timeRemainingString {
    NSTimeInterval time = [self timeRemaining];
    int minutes = ceil(time / 60.0);
    if (minutes < 60) {
        return [NSString stringWithFormat:@"0:%02d", minutes];
    }
    return [NSString stringWithFormat:@"%d:%02d", minutes / 60, minutes % 60];
}

- (void)trigger {
    if (self.isRunningNow) return;
    [self.delegate refreshTimerStarted:self];
    if (self.address) {
        __weak const ANRefreshTimer * weakSelf = self;
        aReq = [[ANAddressRequest alloc] initWithAddress:self.address];
        [aReq requestLocation:^(NSError * e, CLLocation * loc) {
            if (e) [weakSelf gotError:e];
            else [weakSelf gotLocation:loc];
        }];
    } else {
        if (!manager) { // manager is always nil
            manager = [[CLLocationManager alloc] init];
            manager.distanceFilter = kCLDistanceFilterNone;
            manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
            manager.delegate = self;
        }
        [manager startUpdatingLocation];
    }
}

#pragma mark - CLLocationManager -

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation * loc = locations.lastObject;
    if (!loc) return [self gotError:nil];
    [self gotLocation:loc];
}

#pragma mark - NSCoding -

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.address = [aDecoder decodeObjectForKey:@"address"];
        refreshRate = [aDecoder decodeDoubleForKey:@"rate"];
        [self beginNextInterval];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:refreshRate forKey:@"rate"];
    if (self.address) [aCoder encodeObject:self.address forKey:@"address"];
}

#pragma mark - Private -

+ (NSDictionary *)ratesDict {
    return @{@"Every three hours": @(60*60*3),
             @"Every hour": @(60*60),
             @"Every 30 minutes": @(60*30)};
}

- (void)beginNextInterval {
    cReq = nil;
    nextDate = [[NSDate date] dateByAddingTimeInterval:refreshRate];
    [nextTick invalidate];
    nextTick = [NSTimer scheduledTimerWithTimeInterval:refreshRate target:self selector:@selector(trigger)
                                     userInfo:nil repeats:NO];
}

- (void)gotLocation:(CLLocation *)loc {
    [manager stopUpdatingLocation];
    manager = nil;
    aReq = nil;
    cReq = [[ANConditionRequest alloc] initWithLocation:loc appKey:kForecastIOAppKey];
    __weak const ANRefreshTimer * weakSelf = self;
    [cReq requestCondition:^(NSError * e, NSString * condition) {
        [weakSelf beginNextInterval];
        [weakSelf.delegate refreshTimer:self gotState:condition];
    }];
}

- (void)gotError:(NSError *)error {
    aReq = nil;
    cReq = nil;
    [manager stopUpdatingLocation];
    manager = nil;
    [self.delegate refreshTimer:self gotError:error];
}

@end
