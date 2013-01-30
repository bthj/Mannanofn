//
//  NamesTableViewBaseController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 1/30/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataTableViewController.h"


@protocol SetupFetchedResultsControllerDelegate;



@interface NamesTableViewBaseController : CoreDataTableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UIManagedDocument *namesDatabase;

@property (weak, nonatomic) id <SetupFetchedResultsControllerDelegate> fetchedResultsSetupDelegate;

- (void)initializeNamesDatabase;

@end



@protocol SetupFetchedResultsControllerDelegate <NSObject>

- (void)setupFetchedResultsController;

@end