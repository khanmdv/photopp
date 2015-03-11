//
//  PPTag.h
//  Photo++
//
//  Created by Mohtashim Khan on 1/27/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSPTag.h"

@interface PPTag : NSObject

@property (nonatomic, strong) NSString *tagId;
@property (nonatomic, strong) NSString *tagName;
@property (nonatomic, assign) NSInteger tagDisplayOrder;

- (instancetype)initWithTag:(PSPTag *)tag;

- (void)updateTagName:(NSString *)newName;
- (void)updateTagdisplayOrder:(NSInteger)tagDisplayOrder;

@end
