//
//  FavoritesDatabaseSetupUtility.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/5/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import "FavoritesDatabaseSetupUtility.h"

@interface FavoritesDatabaseSetupUtility ()
@property (nonatomic, strong) UIManagedDocument *favoritesDatabase;
@property (nonatomic, strong) UIView *view;
@end


@implementation FavoritesDatabaseSetupUtility

@synthesize favoritesDatabase = _favoritesDatabase;

- (void)userDocument
{
    if( ![[NSFileManager defaultManager] fileExistsAtPath:[self.favoritesDatabase.fileURL path]] ) {
        // does not exist on disk, so create it
        [self.favoritesDatabase saveToURL:self.favoritesDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self.setFavoritesDatabaseDelegate setFavoritesDatabase: self.favoritesDatabase];
        }];
    } else if( self.favoritesDatabase.documentState == UIDocumentStateClosed ) {
        // exists on disk, but we need to open it
        [self.favoritesDatabase openWithCompletionHandler:^(BOOL success) {
            [self.setFavoritesDatabaseDelegate setFavoritesDatabase: self.favoritesDatabase];
        }];
    } else if( self.favoritesDatabase.documentState == UIDocumentStateNormal ) {
        // already open and ready to use
        [self.setFavoritesDatabaseDelegate setFavoritesDatabase: self.favoritesDatabase];
    }
}

- (void)setFavoritesDatabase:(UIManagedDocument *)favoritesDatabase
{
    if( _favoritesDatabase != favoritesDatabase ) {
        _favoritesDatabase = favoritesDatabase;
        if( favoritesDatabase ) {
            [self userDocument];
        }
    }
}

- (void)initializeFavoritesDatabase: (UIView *)view
{
    self.view = view;
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"FavoritesMannanofnDatabase"];
    
    self.favoritesDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
}

@end
