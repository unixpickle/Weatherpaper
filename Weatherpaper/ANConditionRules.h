//
//  ANConditionRules.h
//  Weatherpaper
//
//  Created by Alex Nichol on 1/3/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANVoidQueue.h"

@interface ANConditionRules : NSObject <NSCoding>

@property (readonly) NSMutableArray * conditions;
@property (readonly) NSMutableArray * queues;

+ (ANConditionRules *)defaultConditions;

- (id)initWithConditions:(NSArray *)conds queues:(NSArray *)queues;
- (void)setQueue:(id<ANGeneralImageQueue>)queue forCondition:(NSString *)cond;
- (id<ANGeneralImageQueue>)queueForCondition:(NSString *)cond;

@end
