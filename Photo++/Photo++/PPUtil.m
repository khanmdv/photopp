//
//  PPUtil.m
//  Photo++
//
//  Created by Mohtashim Khan on 1/17/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import "PPUtil.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import "PSPPhotosManager.h"
#import "PSPPhoto.h"
#import <Photos/PHAsset.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHFetchResult.h>
#import <CoreLocation/CoreLocation.h>

@implementation PPUtil

+ (BOOL)checkPhotoAccess
{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];

    if (status == ALAuthorizationStatusAuthorized) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (void)createPhotosIndex
{
    NSMutableArray *arr = [NSMutableArray array];

    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors =
        @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO] ];

    PHFetchResult *photos = [PHAsset fetchAssetsWithOptions:fetchOptions];

    for (int i = 0; i < photos.count; i++) {
        PHAsset *photo = [photos objectAtIndex:i];
        PSPPhoto *asset = [[PSPPhotosManager sharedManager] emptyAssetObject];

        asset.photoId = photo.localIdentifier;
        asset.width = @(photo.pixelWidth);
        asset.height = @(photo.pixelHeight);
        asset.locLatitude = @(photo.location.coordinate.latitude);
        asset.locLongitude = @(photo.location.coordinate.longitude);
        asset.type = @(PPPhotoMediaTypeImage);
        asset.resolved = @(YES);

        NSLog(@"Photo = %@", asset);

        [arr addObject:asset];
    }

    [[PSPPhotosManager sharedManager] saveAll];
    [arr removeAllObjects];

    /*
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
        usingBlock:^(ALAssetsGroup *group, BOOL *stop) {

          // Within the group enumeration block, filter to enumerate just photos.
          [group setAssetsFilter:[ALAssetsFilter allPhotos]];

          // Chooses the photo at the last index
          [group enumerateAssetsWithOptions:NSEnumerationReverse
                                 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                                   // The end of the enumeration is signaled by asset == nil.
                                   if (alAsset) {
                                       ALAssetRepresentation *representation =
                                           [alAsset defaultRepresentation];

                                       NSURL *url = (NSURL *)
                                           [alAsset valueForProperty:ALAssetPropertyAssetURL];

                                       Assets *asset =
                                           [[PPPhotosManager sharedManager] emptyAssetObject];

                                       asset.assetId = representation.filename;
                                       asset.assetURL = url.absoluteString;
                                       asset.assetRank = @(1);

                                       CGSize size = representation.dimensions;

                                       asset.height = @(size.height);
                                       asset.width = @(size.width);
                                       asset.type = @(PPPhotoTypeImage);
                                       asset.resolved = @(YES);

                                       [arr addObject:asset];
                                       NSLog(@"Saving %@", asset);
                                       NSLog(@"Metadata = %@", representation.metadata);
                                   }
                                 }];

          [[PPPhotosManager sharedManager] saveAll];
          [arr removeAllObjects];
        }
        failureBlock:^(NSError *error) {
          // Typically you should handle an error more gracefully than this.
          NSLog(@"No groups");
        }];
     */
}

+ (void)createDefaultTags
{
    int i = 1;
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *tagName in
         @[ @"Travel", @"Important", @"Favorites", @"Family", @"Selfies", @"Work", @"Pets" ]) {

        PSPTag *tag = [[PSPPhotosManager sharedManager] emptyTagObject];

        tag.tagId = [[NSUUID UUID] UUIDString];
        tag.tagName = tagName;
        tag.tagDisplayOrder = @(i);
        tag.tagDescription = tagName;
        i++;

        [arr addObject:tag];
    }

    [[PSPPhotosManager sharedManager] saveAll];
    [arr removeAllObjects];
}

+ (CGSize)textSize:(NSString *)str forFont:(UIFont *)font
{
    return [str sizeWithAttributes:@{ NSFontAttributeName : font }];
}

@end
