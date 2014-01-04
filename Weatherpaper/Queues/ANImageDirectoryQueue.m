//
//  ANImageQueue.m
//  Weatherpaper
//
//  Created by Alex Nichol on 1/3/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANImageDirectoryQueue.h"

@implementation ANImageDirectoryQueue

- (id)init {
    if ((self = [super init])) {
        _completed = [NSMutableArray array];
    }
    return self;
}

- (NSString *)popPath {
    NSArray * listing = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.baseDirectory
                                                                            error:nil];
    if (!listing) return nil;
    for (NSString * name in listing) {
        if ([name hasPrefix:@"."]) continue;
        if ([_completed containsObject:name]) continue;
        [_completed addObject:name];
        return [self.baseDirectory stringByAppendingPathComponent:name];
    }
    [_completed removeAllObjects];
    return [self popPath];
}

- (void)reloadDirectory {
    [_completed removeAllObjects];
}

- (NSString *)queueSourceString {
    return self.baseDirectory;
}

#pragma mark - NSCoding -

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        _completed = [[aDecoder decodeObjectForKey:@"completed"] mutableCopy];
        self.baseDirectory = [aDecoder decodeObjectForKey:@"base"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_completed forKey:@"completed"];
    [aCoder encodeObject:self.baseDirectory forKey:@"base"];
}

@end
