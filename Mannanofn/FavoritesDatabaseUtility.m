//
//  FavoritesDatabaseSetupUtility.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/5/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import "FavoritesDatabaseUtility.h"
#import "Favorite+Create.h"

@interface FavoritesDatabaseUtility ()
@property (nonatomic, strong) UIManagedDocument *favoritesDatabase;
@property (nonatomic, strong) UIView *view;
@end


@implementation FavoritesDatabaseUtility

@synthesize favoritesDatabase = _favoritesDatabase;

- (void)useDocument
{
    if( ![[NSFileManager defaultManager] fileExistsAtPath:[self.favoritesDatabase.fileURL path]] ) {
        // does not exist on disk, so create it
        [self.favoritesDatabase saveToURL:self.favoritesDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if( self.setFavoritesDatabaseDelegate ) {
                [self.setFavoritesDatabaseDelegate setFavoritesDatabase: self.favoritesDatabase];
            }
        }];
    } else if( self.favoritesDatabase.documentState == UIDocumentStateClosed ) {
        // exists on disk, but we need to open it
        [self.favoritesDatabase openWithCompletionHandler:^(BOOL success) {
            if( self.setFavoritesDatabaseDelegate ) {
                [self.setFavoritesDatabaseDelegate setFavoritesDatabase: self.favoritesDatabase];
            }
        }];
    } else if( self.favoritesDatabase.documentState == UIDocumentStateNormal ) {
        // already open and ready to use
        if( self.setFavoritesDatabaseDelegate ) {
            [self.setFavoritesDatabaseDelegate setFavoritesDatabase: self.favoritesDatabase];
        }
    }
}

- (void)setFavoritesDatabase:(UIManagedDocument *)favoritesDatabase
{
    if( _favoritesDatabase != favoritesDatabase ) {
        _favoritesDatabase = favoritesDatabase;
        if( favoritesDatabase ) {
            [self useDocument];
        }
    }
}

- (id)initFavoritesDatabaseForView: (UIView *)view {
    if( self = [super init] ) {
        self.view = view;
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"FavoritesMannanofnDatabase"];
        
        self.favoritesDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    return self;
}


- (BOOL)isInFavorites:(NSString *)name
{
    NSArray *existingFavoritesForName = [Favorite getFavoritesForName:name inContext:self.favoritesDatabase.managedObjectContext];
    return [existingFavoritesForName count];
}

- (BOOL)toggleFavoriteForName:(NSString *)name
{
    BOOL isInFavorites;
    if( [self isInFavorites:name] ) {
        [Favorite removeFavoriteWithName:name inManagedObjectContext:self.favoritesDatabase.managedObjectContext];
        isInFavorites = NO;
    } else {
        [Favorite addFavoriteWithName:name inManagedObjectContext:self.favoritesDatabase.managedObjectContext];
        isInFavorites = YES;
    }
    // UIManagedDocument's autosaving not always working here so...
    [self.favoritesDatabase saveToURL:self.favoritesDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
    
    return isInFavorites;
}


@end
