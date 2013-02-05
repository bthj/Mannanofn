//
//  NamesTableViewBaseController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 1/30/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import "NamesDatabaseSetupUtility.h"
#import "Name+Create.h"
#import "MBProgressHUD.h"
#import "MannanofnGlobalStringConstants.h"



@interface NamesDatabaseSetupUtility ()
@property (nonatomic, strong) UIManagedDocument *namesDatabase;
@property (nonatomic, strong) UIView *view;
@end



@implementation NamesDatabaseSetupUtility

@synthesize namesDatabase = _namesDatabase;



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

- (void)fetchNamesIntoDocument:(UIManagedDocument *)document shouldReset:(BOOL)reset
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Hleð inn nöfnum...";
    dispatch_queue_t seedQ = dispatch_queue_create("Names database seeding", NULL);
    dispatch_async(seedQ, ^{
        NSArray *names = [self getNamesFromJSONSeed];
        [document.managedObjectContext performBlock:^{ // perform in the NSMOC's safe thread (main thread)
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
            
            // !!! TODO: DELETE THIS!
            // sleep a while to show the activity indicator
            //   [NSThread sleepForTimeInterval:arc4random() % 5];
            // !!! TODO: DELETE THIS - end
            
            // Create entity in database for each name from JSON seed
            for( NSDictionary *oneName in names ) {
                [Name nameWithSeedData:oneName inManagedObjectContext:document.managedObjectContext];
            }
            
            //            [document updateChangeCount:UIDocumentChangeDone];
            
            // UIManagedDocument autosaves, but let's save as soon as possible
            [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                
                //                [self setupFetchedResultsController];
            }];
            
            // Write app's version number at the time of this fetch to NSUserDefaults, for reference later.
            NSString *currentBuildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            [[NSUserDefaults standardUserDefaults] setObject:currentBuildVersion forKey:NAMES_READ_FROM_SEED_AT_VERSION];
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    });
    //    dispatch_release(seedQ);
}



- (void)useDocument
{
    if( ![[NSFileManager defaultManager] fileExistsAtPath:[self.namesDatabase.fileURL path]] ) {
        // does not exist on disk, so create it
        [self.namesDatabase saveToURL:self.namesDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {

            [self.fetchedResultsSetupDelegate setNamesDatabase: self.namesDatabase];
            [self fetchNamesIntoDocument:self.namesDatabase shouldReset:NO];
        }];
    } else if( self.namesDatabase.documentState == UIDocumentStateClosed ) {
        // exists on disk, but we need to open it
        [self.namesDatabase openWithCompletionHandler:^(BOOL success) {

            [self.fetchedResultsSetupDelegate setNamesDatabase: self.namesDatabase];
        }];
    } else if( self.namesDatabase.documentState == UIDocumentStateNormal ) {
        // already open and ready to use
        [self.fetchedResultsSetupDelegate setNamesDatabase: self.namesDatabase];
    }
    
    NSString *namesReadFromSeedAtVersion = [[NSUserDefaults standardUserDefaults] objectForKey:NAMES_READ_FROM_SEED_AT_VERSION];
    NSString *currentBuildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if( namesReadFromSeedAtVersion && ![currentBuildVersion isEqualToString:namesReadFromSeedAtVersion] ) {
        // current app version doesn't match the one in NSUserDefault's NAMES_READ_FROM_SEED_AT_VERSION
        // let's delete everything from the Name table and read in again from the seed
        [self fetchNamesIntoDocument:self.namesDatabase shouldReset:YES];
    }
}

- (void)setNamesDatabase:(UIManagedDocument *)namesDatabase
{
    if( _namesDatabase != namesDatabase ) {
        _namesDatabase = namesDatabase;
        if( namesDatabase ) {
            [self useDocument];
        }
    }
}

- (void)initializeNamesDatabase: (UIView *)view;
{
    self.view = view;
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"MannanofnDatabase"];
    
    self.namesDatabase = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create this for us on disk
}

@end
