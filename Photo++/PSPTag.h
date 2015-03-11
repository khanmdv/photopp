//
//  Tags.h
//  Photo++
//
//  Created by Mohtashim Khan on 3/4/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PSPPhoto;

@interface PSPTag : NSManagedObject

@property (nonatomic, retain) NSNumber * private;
@property (nonatomic, retain) NSString * tagColor;
@property (nonatomic, retain) NSString * tagDescription;
@property (nonatomic, retain) NSNumber * tagDisplayOrder;
@property (nonatomic, retain) NSString * tagId;
@property (nonatomic, retain) NSString * tagName;
@property (nonatomic, retain) NSNumber * permanent;
@property (nonatomic, retain) NSSet *assets;
@end

@interface PSPTag (CoreDataGeneratedAccessors)

- (void)addAssetsObject:(PSPPhoto *)value;
- (void)removeAssetsObject:(PSPPhoto *)value;
- (void)addAssets:(NSSet *)values;
- (void)removeAssets:(NSSet *)values;

@end
