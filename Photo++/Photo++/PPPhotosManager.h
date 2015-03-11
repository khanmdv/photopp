//
//  PhotosManager.h
//  Photo++
//
//  Created by Mohtashim Khan on 1/27/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Assets.h"
#import "Tags.h"
#import "PPAsset.h"
#import "PPTag.h"

#import <CoreData/CoreData.h>

@interface PPPhotosManager : NSObject

+ (PPPhotosManager *)sharedManager;

- (NSArray *)fetchAllPhotos;
- (NSArray *)fetchAllTags;

- (Assets *)photoWithId:(NSString *)photoId;
- (Tags *)tagWithId:(NSString *)tagName;
- (NSArray *)photosOfTag:(NSString *)tagName;

- (Assets *)emptyAssetObject;
- (Tags *)emptyTagObject;

- (NSArray *)fetchAllPHAssets;

- (void)resolvePhotos;

- (void)saveAll;

@end
