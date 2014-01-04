//
//  ANConditionRequest.h
//  Weatherpaper
//
//  Created by Alex Nichol on 1/3/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANAsyncRequest.h"
#import <CoreLocation/CoreLocation.h>

typedef void (^ANConditionCallback)(NSError * e, NSString * condition);

@interface ANConditionRequest : ANAsyncRequest

- (id)initWithLocation:(CLLocation *)location appKey:(NSString *)appKey;
- (void)requestCondition:(ANConditionCallback)cb;

@end
