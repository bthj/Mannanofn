//
//  NamesTableViewCategoryControllerViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 1/30/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NamesDatabaseSetupUtility.h"

@interface NamesTableViewCategoryController : CoreDataTableViewController <SetupFetchedResultsControllerDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UIManagedDocument *namesDatabase;

@end