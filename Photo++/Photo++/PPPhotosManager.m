//
//  PhotosManager.m
//  Photo++
//
//  Created by Mohtashim Khan on 1/27/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import "PPPhotosManager.h"
#import <Photos/PHAsset.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHFetchResult.h>
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define kPPAssetsEntity @"Assets"
#define kPPTagsEntity @"Tags"
#define kPPAssetsTagsEntity @"AssetsTags"

@interface PPPhotosManager ()

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) dispatch_queue_t queue;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

@implementation PPPhotosManager

+ (PPPhotosManager *)sharedManager
{
    static PPPhotosManager *photosManager;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      photosManager = [[PPPhotosManager alloc] init];
    });

    return photosManager;
}

- (instancetype)init
{
    if (self = [super init]) {

        _queue = dispatch_queue_create("com.xyz.PhotoManagerQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Public
- (void)saveAll
{
    [self saveContext];
}

- (NSArray *)fetchAllPhotos
{
    __block NSArray *results;

    dispatch_sync(self.queue, ^{
      NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:kPPAssetsEntity];

      NSError *error;
      results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    });

    return results;
}

- (NSArray *)fetchAllTags
{
    __block NSMutableArray *results = [NSMutableArray array];

    dispatch_sync(self.queue, ^{
      NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:kPPTagsEntity];
      NSEntityDescription *entity = [NSEntityDescription entityForName:kPPTagsEntity
                                                inManagedObjectContext:self.managedObjectContext];

      fetchRequest.propertiesToFetch =
          [NSArray arrayWithObject:[[entity propertiesByName] objectForKey:@"tagName"]];

      fetchRequest.returnsDistinctResults = YES;
      fetchRequest.resultType = NSDictionaryResultType;

      NSError *error;
      NSArray *dicts = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

      for (NSDictionary *dict in dicts) {

          [results addObject:dict[@"tagName"]];
      }

    });

    return results;
}

- (NSArray *)photosOfTag:(NSString *)tagName
{
    __block NSArray *photos;

    Tags *tag = [self tagWithId:tagName];

    dispatch_sync(self.queue, ^{

      NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:kPPAssetsEntity];
      [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"tags.tagName contains[cd] %@",
                                                                  tag.tagName]];
      NSError *error;

      photos = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    });

    return photos;
}

- (Tags *)emptyTagObject
{
    Tags *tag
        = (Tags *)[NSEntityDescription insertNewObjectForEntityForName:kPPTagsEntity
                                                inManagedObjectContext:self.managedObjectContext];

    return tag;
}

- (Assets *)emptyAssetObject
{
    Assets *asset
        = (Assets *)[NSEntityDescription insertNewObjectForEntityForName:kPPAssetsEntity
                                                  inManagedObjectContext:self.managedObjectContext];

    return asset;
}

- (Assets *)photoWithId:(NSString *)photoId
{
    __block Assets *asset;

    dispatch_sync(self.queue, ^{
      NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:kPPAssetsEntity];

      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"photoId = %@", photoId];
      [fetchRequest setPredicate:predicate];

      NSError *error;
      NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

      if (results.count > 0) {
          asset = results[0];
      }
    });

    return asset;
}

- (Tags *)tagWithId:(NSString *)tagName
{
    __block Tags *tag;

    dispatch_sync(self.queue, ^{
      NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:kPPTagsEntity];

      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tagName = %@", tagName];
      [fetchRequest setPredicate:predicate];

      NSError *error;
      NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

      if (results.count > 0) {
          tag = results[0];
      }
    });

    return tag;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory
{
    // The directory the application uses to store the Core Data store file. This code uses a
    // directory named "com.xyz.Photo__" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel
{
    // The managed object model for the application. It is a fatal error for the application not to
    // be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Photos_" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    // The persistent store coordinator for the application. This implementation creates and return
    // a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    // Create the coordinator and store

    _persistentStoreCoordinator =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSURL *storeURL = [[NSFileManager defaultManager]
        containerURLForSecurityApplicationGroupIdentifier:@"group.PhotosPlus"];
    storeURL = [storeURL URLByAppendingPathComponent:@"Photos_.sqlite"];

    NSError *error = nil;
    NSString *failureReason =
        @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use
        // this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    // Returns the managed object context for the application (which is already bound to the
    // persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

- (void)mergeChangesFrom_iCloud:(NSNotification *)notification
{

    NSLog(@"Merging in changes from iCloud...");

    NSManagedObjectContext *moc = [self managedObjectContext];

    [moc performBlock:^{

      [moc mergeChangesFromContextDidSaveNotification:notification];

      NSNotification *refreshNotification =
          [NSNotification notificationWithName:@"SomethingChanged"
                                        object:self
                                      userInfo:[notification userInfo]];

      [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
    }];
}

#pragma mark - Core Data Saving support

- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not
            // use this function in a shipping application, although it may be useful during
            // development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSArray *)fetchAllPHAssets
{
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors =
        @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO] ];

    PHFetchResult *photos = [PHAsset fetchAssetsWithOptions:fetchOptions];

    for (int i = 0; i < photos.count; i++) {
        PHAsset *photo = [photos objectAtIndex:i];
        NSLog(@"Photo = %@", photo);
    }

    return @[];
}

- (void)resolvePhotos
{

    __block NSArray *results;

    dispatch_sync(self.queue, ^{

      NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:kPPAssetsEntity];
      [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"resolved == 0"]];
      NSError *error;

      results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    });

    if (results.count == 0) {
        return;
    }

    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    for (Assets *asset in results) {

        map[asset.photoId] = asset;
    }

    NSInteger totalPhotosToResolve = map.count;
    __block NSInteger countOfResolved = 0;

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

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

                                       NSString *fileName = representation.filename;
                                       NSURL *url = (NSURL *)
                                           [alAsset valueForProperty:ALAssetPropertyAssetURL];

                                       Assets *asst = map[fileName];

                                       if (asst) {
                                           asst.assetURL = url.absoluteString;
                                           asst.resolved = @(YES);

                                           PHFetchResult *result =
                                               [PHAsset fetchAssetsWithALAssetURLs:@[ url ]
                                                                           options:nil];

                                           if (result.count > 0) {
                                               PHAsset *foundAsset = [result firstObject];
                                               asst.photoId = foundAsset.localIdentifier;
                                           }

                                           countOfResolved++;
                                       }

                                       if (countOfResolved == totalPhotosToResolve) {

                                           [self saveAll];
                                           *innerStop = YES;
                                           *stop = YES;
                                       }
                                   }
                                 }];

        }
        failureBlock:^(NSError *error) {
          // Typically you should handle an error more gracefully than this.
          NSLog(@"No groups");
        }];
}

@end
