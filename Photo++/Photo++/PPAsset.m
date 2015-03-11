//
//  PPAsset.m
//  Photo++
//
//  Created by Mohtashim Khan on 1/27/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import "PPAsset.h"

@interface PPAsset ()

@property (nonatomic, strong) PSPPhoto *asset;

@end

@implementation PPAsset

@dynamic assetId, assetRank, assetURL;

- (instancetype)initWithAsset:(PSPPhoto *)asset
{
    if (self = [super init]) {

        _asset = asset;
    }
    return self;
}

- (NSString *)assetId
{
    return self.asset.photoId;
}

- (NSString *)assetURL
{
    return self.asset.assetURL;
}

- (NSInteger)assetRank
{
    return [self.asset.rank integerValue];
}

- (void)incrementAssetRank
{
    self.asset.rank = @([self.asset.rank integerValue] + 1);
}

@end
