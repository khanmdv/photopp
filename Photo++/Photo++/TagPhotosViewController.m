//
//  TagPhotosViewController.m
//  Photo++
//
//  Created by Mohtashim Khan on 2/9/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import "TagPhotosViewController.h"
#import "PSPPhotosManager.h"
#import <Photos/PHAsset.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHFetchResult.h>
#import <Photos/PHImageManager.h>
#import "PhotoDetailViewController.h"

#import "TagCellTableViewCell.h"

typedef struct {
    CGImageRef img;
    float width;
    float height;
} ThumbnailImg;

@interface TagPhotosViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;

@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbnails;

@end

@implementation TagPhotosViewController

- (void)p_renderPhotos
{
    NSAssert([NSThread isMainThread], @"Should be on main thread");

    [self.photosCollectionView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.photosCollectionView
                       registerNib:[UINib nibWithNibName:@"TNCell" bundle:[NSBundle mainBundle]]
        forCellWithReuseIdentifier:@"TNCell"];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{

      self.photos = [[PSPPhotosManager sharedManager] photosOfTag:self.tagName];

      dispatch_async(dispatch_get_main_queue(), ^{
        [self p_renderPhotos];
      });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:@"TNCell" forIndexPath:indexPath];

    UIImageView *imgView = (UIImageView *)[cell viewWithTag:99];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];

    cell.tag = indexPath.row;
    CGSize size = cell.frame.size;

    PSPPhoto *myasset = (PSPPhoto *)self.photos[indexPath.row];

    // dispatch_async(dispatch_get_global_queue(0, 0), ^{

    PHFetchResult *result1 =
        [PHAsset fetchAssetsWithLocalIdentifiers:@[ myasset.photoId ] options:nil];

    PHAsset *asset = [result1 firstObject];

    NSLog(@"Asset to fill = %@", asset);
    PHImageManager *manager = [PHImageManager defaultManager];

    [manager requestImageForAsset:asset
                       targetSize:size
                      contentMode:PHImageContentModeAspectFill
                          options:nil
                    resultHandler:^(UIImage *result, NSDictionary *info) {
                      NSLog(@"got the thumbnail");

                      imgView.image = result;
                      [spinner stopAnimating];
                    }];

    //});

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"PhotoDetail" sender:cell];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PhotoDetailViewController *photoVC
        = (PhotoDetailViewController *)segue.destinationViewController;

    UICollectionViewCell *cell = (UICollectionViewCell *)sender;
    PSPPhoto *myasset = (PSPPhoto *)self.photos[cell.tag];
    photoVC.photoURL = myasset.photoId;
}

@end
