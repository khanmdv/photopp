//
//  PPUtil.h
//  Photo++
//
//  Created by Mohtashim Khan on 1/17/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PPUtil : NSObject

+ (BOOL)checkPhotoAccess;

+ (void)createPhotosIndex;
+ (void)createDefaultTags;

+ (CGSize)textSize:(NSString *)str forFont:(UIFont *)font;

@end
