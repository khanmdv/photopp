//
//  PhotoDetailViewController.m
//  Photo++
//
//  Created by Mohtashim Khan on 2/15/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/PHAsset.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHFetchResult.h>
#import <Photos/PHImageManager.h>

@interface PhotoDetailViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIScrollView *imgScrollView;

@end

@implementation PhotoDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // self.imgScrollView.frame = self.view.bounds;
    // self.imgView.frame = self.view.bounds;

    if (self.photoURL) {

        PHFetchResult *result1 =
            [PHAsset fetchAssetsWithLocalIdentifiers:@[ self.photoURL ] options:nil];

        if (result1.count == 0) return;

        PHAsset *asset = [result1 firstObject];

        PHImageManager *manager = [PHImageManager defaultManager];

        [manager requestImageForAsset:asset
                           targetSize:self.imgView.frame.size
                          contentMode:PHImageContentModeAspectFill
                              options:nil
                        resultHandler:^(UIImage *result, NSDictionary *info) {

                          self.imgView.image = result;
                          [self.spinner stopAnimating];

                        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imgView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
