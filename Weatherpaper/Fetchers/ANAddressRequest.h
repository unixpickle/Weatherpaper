//
//  ANAddressRequest.h
//  Weatherpaper
//
//  Created by Alex Nichol on 1/3/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANAsyncRequest.h"
#import <CoreLocation/CoreLocation.h>

typedef void (^ANLocationCallback)(NSError * e, CLLocation * loc);

@interface ANAddressRequest : ANAsyncRequest

- (id)initWithAddress:(NSString *)addr;
- (void)requestLocation:(ANLocationCallback)cb;

@end
