//
//  AppDelegate.m
//  Photo++
//
//  Created by Mohtashim Khan on 1/17/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import "AppDelegate.h"
#import "PPUtil.h"
#import "PPPhotosManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    BOOL photoAccessAuthorized = [PPUtil checkPhotoAccess];

    if (!photoAccessAuthorized) {
        UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:@"Photo Access"
                                       message:@"Please give this app permission to access your "
                                       @"photos. You can do the same from your settings app as well"
                                      delegate:nil
                             cancelButtonTitle:@"Close"
                             otherButtonTitles:nil, nil];
        [alert show];
    }

    NSArray *assets = [[PPPhotosManager sharedManager] fetchAllPhotos];

    if (assets.count == 0) {

        [PPUtil createPhotosIndex];
        assets = [[PPPhotosManager sharedManager] fetchAllPhotos];
    }

    NSLog(@"Photos = %@", assets);

    NSArray *tags = [[PPPhotosManager sharedManager] fetchAllTags];

    if (tags.count == 0) {
        //[PPUtil createDefaultTags];
        tags = [[PPPhotosManager sharedManager] fetchAllTags];
    }

    NSLog(@"Tags = %@", tags);

    [[PPPhotosManager sharedManager] resolvePhotos];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for
    // certain types of temporary interruptions (such as an incoming phone call or SMS message) or
    // when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame
    // rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store
    // enough application state information to restore your application to its current state in case
    // it is terminated later.
    // If your application supports background execution, this method is called instead of
    // applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      [[PPPhotosManager sharedManager] resolvePhotos];
    });
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive.
    // If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also
    // applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[PPPhotosManager sharedManager] saveAll];
}

@end
