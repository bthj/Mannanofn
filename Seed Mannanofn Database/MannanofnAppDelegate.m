//
//  MannanofnAppDelegate.m
//  Seed Mannanofn Database
//
//  Created by Björn Þór Jónsson on 10/10/12.
//  Copyright (c) 2012 Síminn. All rights reserved.
//

#import "MannanofnAppDelegate.h"

#import "Name+Create.h"

@implementation MannanofnAppDelegate



- (NSArray *)getNamesFromJSONSeed
{
    NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"names" ofType:@"json"]];
    NSError *parseError = nil;
    NSArray *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&parseError] : nil;
    
    if( parseError == nil ) {
        return results;
    }
    return nil;
}

- (NSFetchRequest *)getRequestForAllNames
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Name"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    // no predicate because we want all names
    return request;
}

- (void)fetchNamesIntoDocument:(UIManagedDocument *)document:(BOOL)reset
{
    NSLog(@"Start fetching names into document");
    
    NSArray *names = [self getNamesFromJSONSeed];
    if( reset ) {
        // Delete all entries from Name table
        NSFetchRequest *request = [self getRequestForAllNames];
        NSError *error = nil;
        NSArray *namesToDelete = [document.managedObjectContext executeFetchRequest:request error:&error];
        for( Name *oneNameToDelete in namesToDelete ) {
            [document.managedObjectContext deleteObject:oneNameToDelete];
        }
        [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
    }
    // Create entity in database for each name from JSON seed
    for( NSDictionary *oneName in names ) {
        [Name nameWithSeedData:oneName inManagedObjectContext:document.managedObjectContext];
    }
    // UIManagedDocument autosaves, but let's save as soon as possible
    [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
    
    NSLog(@"Finished fetching names into document.");
}


- (void)seedDatabase:(UIManagedDocument *)database
{
    if( ![[NSFileManager defaultManager] fileExistsAtPath:[database.fileURL path]] ) {
        // does not exist on disk, so create it
        [database saveToURL:database.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self fetchNamesIntoDocument:database:NO];
        }];
    } else if( database.documentState == UIDocumentStateClosed ) {
        // exists on disk, but we need to open it
        [database openWithCompletionHandler:^(BOOL success) {
            [self fetchNamesIntoDocument:database:YES];
        }];
    } else if( database.documentState == UIDocumentStateNormal ) {
        // already open and ready to use
        [self fetchNamesIntoDocument:database:YES];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"MannanofnDatabase"];
    
    UIManagedDocument *namesDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    
    [self seedDatabase:namesDatabase];
    
    
    
    // Create Window and View Controllers
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

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
