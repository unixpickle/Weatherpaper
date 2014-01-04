//
//  ANConditionRules.m
//  Weatherpaper
//
//  Created by Alex Nichol on 1/3/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANConditionRules.h"

@implementation ANConditionRules

+ (ANConditionRules *)defaultConditions {
    NSArray * conds = @[@"clear-day", @"clear-night", @"rain", @"snow", @"sleet", @"wind", @"fog", @"cloudy", @"partly-cloudy-day", @"partly-cloudy-night"];
    NSMutableArray * queues = [NSMutableArray array];
    for (int i = 0; i < conds.count; i++) {
        [queues addObject:[[ANVoidQueue alloc] init]];
    }
    return [[ANConditionRules alloc] initWithConditions:conds queues:queues];
}

- (id)initWithConditions:(NSArray *)conds queues:(NSArray *)queues {
    if ((self = [super init])) {
        _conditions = [conds mutableCopy];
        _queues = [queues mutableCopy];
    }
    return self;
}

- (void)setQueue:(id<ANGeneralImageQueue>)queue forCondition:(NSString *)cond {
    if (![_conditions containsObject:cond]) return;
    NSInteger index = [_conditions indexOfObject:cond];
    _queues[index] = queue;
}

- (id<ANGeneralImageQueue>)queueForCondition:(NSString *)cond {
    if (![_conditions containsObject:cond]) return nil;
    NSInteger index = [_conditions indexOfObject:cond];
    return _queues[index];
}

#pragma mark - NSCoding -

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        _conditions = [[aDecoder decodeObjectForKey:@"conditions"] mutableCopy];
        _queues = [[aDecoder decodeObjectForKey:@"queues"] mutableCopy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_conditions forKey:@"conditions"];
    [aCoder encodeObject:_queues forKey:@"queues"];
}

@end
