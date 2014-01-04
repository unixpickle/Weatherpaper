//
//  ANConditionRequest.m
//  Weatherpaper
//
//  Created by Alex Nichol on 1/3/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANConditionRequest.h"

@implementation ANConditionRequest

- (id)initWithLocation:(CLLocation *)location appKey:(NSString *)appKey {
    NSString * string = [NSString stringWithFormat:@"https://api.forecast.io/forecast/%@/%lf,%lf",
                         appKey, location.coordinate.latitude, location.coordinate.longitude];
    self = [super initWithURL:[NSURL URLWithString:string]];
    return self;
}

- (void)requestCondition:(ANConditionCallback)cb {
    [self sendWithCallback:^(NSError * e, NSURLResponse * r, NSData * d) {
        if (e) return cb(e, nil);
        NSError * error = nil;
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:d options:0 error:&error];
        if (![dict isKindOfClass:[NSDictionary class]]) {
            return cb(error, nil);
        }
        NSString * info = dict[@"currently"][@"icon"];
        if (!info) {
            return cb([NSError errorWithDomain:@"ANConditionNotAvailable" code:1
                                      userInfo:@{NSLocalizedDescriptionKey: @"No condition returned by forecast.io"}], nil);
        }
        cb(nil, info);
    }];
}

@end
