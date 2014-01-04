//
//  ANAsyncRequest.h
//  Weatherpaper
//
//  Created by Alex Nichol on 1/3/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ANAsyncCallback)(NSError * e, NSURLResponse * r, NSData * d);

@interface ANAsyncRequest : NSMutableURLRequest <NSURLConnectionDelegate> {
    __weak NSURLConnection * _connection;
    ANAsyncCallback _callback;
    NSURLResponse * _response;
    NSMutableData * _data;
}

+ (void)getURL:(NSURL *)r callback:(ANAsyncCallback)cb;
- (void)cancel;
- (void)sendWithCallback:(ANAsyncCallback)callback;

@end
