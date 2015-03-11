//
//  TagCellTableViewCell.h
//  Photo++
//
//  Created by Mohtashim Khan on 3/8/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *tagNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *photoCountLbl;
@property (weak, nonatomic) IBOutlet UILabel *videoCountLbl;

@end
