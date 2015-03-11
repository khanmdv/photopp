//
//  PPTagButton.h
//  Photo++
//
//  Created by Mohtashim Khan on 1/23/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PPTagButton;

typedef void (^ButtonTapHandler)(BOOL selected, NSString *tagName);

@interface PPTagButton : UIView

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                     selected:(BOOL)selected
                andTapHandler:(ButtonTapHandler)tapHandler;

@end
