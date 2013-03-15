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


- (void)useDocument
{
    if( self.namesDatabase.documentState == UIDocumentStateClosed ) {
        // exists on disk, but we need to open it
        
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.labelText = @"Hleð inn nöfnum...";  // HUD closed in the table view controller
        
        [self.namesDatabase openWithCompletionHandler:^(BOOL success) {
            
            [self.fetchedResultsSetupDelegate setNamesDatabase: self.namesDatabase];
        }];
    } else if( self.namesDatabase.documentState == UIDocumentStateNormal ) {
        // already open and ready to use
        [self.fetchedResultsSetupDelegate setNamesDatabase: self.namesDatabase];
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

- (id)initNamesDatabaseForView: (UIView *)view;
{
    if( self = [super init] ) {
        self.view = view;
        
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"MannanofnDatabase"];
        
        self.namesDatabase = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create this for us on disk
    }
    return self;
}

@end
