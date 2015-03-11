//
//  PPAsset.h
//  Photo++
//
//  Created by Mohtashim Khan on 1/27/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import "PSPPhoto.h"
#import <Foundation/Foundation.h>

@interface PPAsset : NSObject

@property (nonatomic, strong, readonly) NSString *assetId;
@property (nonatomic, strong, readonly) NSString *assetURL;
@property (nonatomic, assign, readonly) NSInteger assetRank;

- (instancetype)initWithAsset:(PSPPhoto *)asset;

- (void)incrementAssetRank;

@end
