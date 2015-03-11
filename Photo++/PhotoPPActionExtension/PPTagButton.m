//
//  PPTagButton.m
//  Photo++
//
//  Created by Mohtashim Khan on 1/23/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import "PPTagButton.h"

@interface PPTagButton ()

@property (nonatomic, strong) ButtonTapHandler tapHandler;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, strong) NSString *tagName;

@end

@implementation PPTagButton

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                     selected:(BOOL)selected
                andTapHandler:(ButtonTapHandler)tapHandler
{
    if (self = [super initWithFrame:frame]) {

        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"PPTagButton" owner:self options:nil];
        self = views[0];
        self.frame = frame;

        self.layer.borderWidth = 1.0f;
        self.layer.borderColor =
            [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:0.4f].CGColor;
        self.layer.cornerRadius = 12.0;

        UIButton *btn = (UIButton *)[self viewWithTag:10];

        [btn setTitle:title forState:UIControlStateNormal];
        [btn addTarget:self
                      action:@selector(handleTagBtnTap:)
            forControlEvents:UIControlEventTouchUpInside];

        self.selected = selected;
        self.tapHandler = tapHandler;
        self.tagName = title;

        if (self.selected) {
            self.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.4];
        }
    }
    return self;
}

- (void)handleTagBtnTap:(id)sender
{
    self.selected = !self.selected;

    if (self.selected) {
        self.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.4];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
    }

    if (self.tapHandler) {
        self.tapHandler(self.selected, self.tagName);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
