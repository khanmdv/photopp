//
//  Assets.m
//  Photo++
//
//  Created by Mohtashim Khan on 3/4/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import "Assets.h"
#import "Tags.h"

@implementation Assets

@dynamic photoId;
@dynamic rank;
@dynamic assetURL;
@dynamic height;
@dynamic resolved;
@dynamic type;
@dynamic width;
@dynamic locLatitude;
@dynamic locLongitude;
@dynamic tags;

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ photoId = %@ }", self.photoId];
}

@end
