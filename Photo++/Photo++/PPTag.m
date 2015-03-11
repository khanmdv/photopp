//
//  PPTag.m
//  Photo++
//
//  Created by Mohtashim Khan on 1/27/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import "PPTag.h"

@interface PPTag ()

@property (nonatomic, strong) PSPTag *tag;

@end

@implementation PPTag

@dynamic tagId, tagDisplayOrder, tagName;

- (instancetype)initWithTag:(PSPTag *)tag
{
    if (self = [super init]) {
        _tag = tag;
    }
    return self;
}

- (NSString *)tagId
{
    return self.tag.tagId;
}

- (NSString *)tagName
{
    return self.tag.tagName;
}

- (NSInteger)tagDisplayOrder
{
    return [self.tag.tagDisplayOrder integerValue];
}

- (void)updateTagName:(NSString *)newName
{
    self.tag.tagName = newName;
}

- (void)updateTagdisplayOrder:(NSInteger)tagDisplayOrder
{
    self.tag.tagDisplayOrder = [NSNumber numberWithLong:tagDisplayOrder];
}

@end
