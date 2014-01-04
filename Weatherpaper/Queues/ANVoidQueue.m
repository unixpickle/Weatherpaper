//
//  ANVoidQueue.m
//  Weatherpaper
//
//  Created by Alex Nichol on 1/3/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANVoidQueue.h"

@implementation ANVoidQueue

- (NSImage *)popPath {
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
}

- (NSString *)queueSourceString {
    return @"";
}

@end
