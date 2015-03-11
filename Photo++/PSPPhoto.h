//
//  Assets.h
//  Photo++
//
//  Created by Mohtashim Khan on 3/4/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSUInteger, PPPhotoMediaType) {
    PPPhotoMediaTypeImage = 0,
    PPPhotoMediaTypeVideo = 1
};

@class PSPTag;

@interface PSPPhoto : NSManagedObject

@property (nonatomic, retain) NSString *photoId;
@property (nonatomic, retain) NSNumber *rank;
@property (nonatomic, retain) NSString *assetURL;
@property (nonatomic, retain) NSNumber *height;
@property (nonatomic, retain) NSNumber *resolved;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) NSNumber *width;
@property (nonatomic, retain) NSNumber *locLatitude;
@property (nonatomic, retain) NSNumber *locLongitude;
@property (nonatomic, retain) NSSet *tags;
@end

@interface PSPPhoto (CoreDataGeneratedAccessors)

- (void)addTagsObject:(PSPTag *)value;
- (void)removeTagsObject:(PSPTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
