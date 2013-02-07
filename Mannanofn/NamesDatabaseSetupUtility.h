//
//  NamesTableViewBaseController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 1/30/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataTableViewController.h"


@protocol SetNamesDatabaseDelegate;



@interface NamesDatabaseSetupUtility : NSObject


@property (weak, nonatomic) id <SetNamesDatabaseDelegate> fetchedResultsSetupDelegate;

- (id)initNamesDatabaseForView: (UIView *)view;

@end



@protocol SetNamesDatabaseDelegate <NSObject>

- (void)setNamesDatabase:(UIManagedDocument *)namesDatabase;

@end