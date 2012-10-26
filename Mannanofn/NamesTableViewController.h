//
//  NamesTableViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 8/21/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"


@interface NamesTableViewController : CoreDataTableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UIManagedDocument *namesDatabase;

@property (nonatomic, strong) NSString *genderSelection;
@property (nonatomic, strong) NSString *categorySelection;

@property (nonatomic, strong) NSString *namesOrder;

@end