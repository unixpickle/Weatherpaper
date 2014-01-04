//
//  ANGeneralImageQueue.h
//  Weatherpaper
//
//  Created by Alex Nichol on 1/3/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

@protocol ANGeneralImageQueue <NSObject, NSCoding>

- (NSString *)popPath;
- (NSString *)queueSourceString;

@end
