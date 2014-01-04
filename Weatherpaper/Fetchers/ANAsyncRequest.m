//
//  ANAsyncRequest.m
//  Weatherpaper
//
//  Created by Alex Nichol on 1/3/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANAsyncRequest.h"

@implementation ANAsyncRequest

+ (void)getURL:(NSURL *)r callback:(ANAsyncCallback)cb {
    ANAsyncRequest * req = [[ANAsyncRequest alloc] initWithURL:r];
    [req sendWithCallback:cb];
}

- (void)cancel {
    [_connection cancel];
}

- (void)sendWithCallback:(ANAsyncCallback)callback {
    _data = [NSMutableData data];
    _callback = callback;
    _connection = [NSURLConnection connectionWithRequest:self delegate:self];
}

#pragma mark - Delegate -

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _callback(error, _response, nil);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    _callback(nil, _response, _data);
}

@end
