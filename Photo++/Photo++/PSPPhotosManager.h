//
//  PhotosManager.h
//  Photo++
//
//  Created by Mohtashim Khan on 1/27/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSPPhoto.h"
#import "PSPTag.h"
#import "PPAsset.h"
#import "PPTag.h"

#import <CoreData/CoreData.h>

@interface PSPPhotosManager : NSObject

+ (PSPPhotosManager *)sharedManager;

- (NSArray *)fetchAllPhotos;
- (NSArray *)fetchAllTags;

- (PSPPhoto *)photoWithId:(NSString *)photoId;
- (PSPTag *)tagWithId:(NSString *)tagName;
- (NSArray *)photosOfTag:(NSString *)tagName;

- (PSPPhoto *)emptyAssetObject;
- (PSPTag *)emptyTagObject;

- (NSArray *)fetchAllPHAssets;

- (void)resolvePhotos;

- (void)saveAll;

@end
