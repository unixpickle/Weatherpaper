//
//  ANAddressRequest.m
//  Weatherpaper
//
//  Created by Alex Nichol on 1/3/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANAddressRequest.h"

@implementation ANAddressRequest

- (id)initWithAddress:(NSString *)addr {
    NSString * address = [addr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    address = [address stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
    address = [address stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    NSString * string = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", address];
    self = [super initWithURL:[NSURL URLWithString:string]];
    return self;
}

- (void)requestLocation:(ANLocationCallback)cb {
    [super sendWithCallback:^(NSError * e, NSURLResponse * r, NSData * d) {
        if (e) return cb(e, nil);
        NSError * error = nil;
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:d options:0 error:&error];
        if (![dict isKindOfClass:[NSDictionary class]]) {
            return cb(error, nil);
        }
        for (NSDictionary * result in dict[@"results"]) {
            NSDictionary * location = result[@"geometry"][@"location"];
            NSNumber * lat = location[@"lat"];
            NSNumber * lon = location[@"lng"];
            if ([lat isKindOfClass:[NSNumber class]] && [lon isKindOfClass:[NSNumber class]]) {
                return cb(nil, [[CLLocation alloc] initWithLatitude:lat.doubleValue
                                                          longitude:lon.doubleValue]);
            }
        }
        cb([NSError errorWithDomain:@"ANAddressNotFound" code:1
                           userInfo:@{NSLocalizedDescriptionKey: @"No lat+lon pair found."}], nil);
    }];
}

@end
