//
//  MannanofnAppDelegate.m
//  Mannanofn
//
//  Created by Bjorn Thor Jonsson on 4/23/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#import "MannanofnAppDelegate.h"

#define NAMES_READ_FROM_SEED_AT_VERSION @"namesReadFromSeedAtVersion"

@implementation MannanofnAppDelegate

@synthesize window = _window;



- (void)copyPreloadedDatabaseToStoreLocation:(NSURL *)storeUrl
{
//    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"MannanofnDatabase"];
//    NSString *documentsFolderPath = [documentsDirectory stringByAppendingPathComponent:@"yourUIManagedDocument"];
    
    
//    NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"MannanofnDatabase" ofType:@"sqlite"];
//    if( defaultStorePath ) {
    if( bundlePath ) {
        
        [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:[storeUrl path] error:NULL];
        
        // let's open the newly copied document
        UIManagedDocument *mannanofn = [[UIManagedDocument alloc] initWithFileURL:storeUrl];
        [mannanofn openWithCompletionHandler:^(BOOL success) {

            // Write app's version number at the time of this fetch to NSUserDefaults, for reference later.
            NSString *currentBuildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            [[NSUserDefaults standardUserDefaults] setObject:currentBuildVersion forKey:NAMES_READ_FROM_SEED_AT_VERSION];
        }];
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
/*
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"MannanofnDatabase"];
    NSString *namesReadFromSeedAtVersion = [[NSUserDefaults standardUserDefaults] objectForKey:NAMES_READ_FROM_SEED_AT_VERSION];
    NSString *currentBuildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    bool databaseNotExists = ![[NSFileManager defaultManager] fileExistsAtPath:[url path]];
    bool isDBSeedAndCurrentVersionInequal = namesReadFromSeedAtVersion && ![currentBuildVersion isEqualToString:namesReadFromSeedAtVersion];
    if( databaseNotExists || isDBSeedAndCurrentVersionInequal ) {
        // db doesn't exist
        // OR
        // current app version doesn't match the one in NSUserDefault's NAMES_READ_FROM_SEED_AT_VERSION
        // let's copy in the pre-populated database
        
        [self copyPreloadedDatabaseToStoreLocation:url];
    }
*/
    

//    [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:100.0f/255.0f blue:40.0f/255.0f alpha:1.0f]];
    

    // set locale for sorting of Core Data
    NSArray *languages = [NSArray arrayWithObject:@"is-IS"];
    [[NSUserDefaults standardUserDefaults] setObject:languages forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
