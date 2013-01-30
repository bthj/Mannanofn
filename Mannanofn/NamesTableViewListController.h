//
//  NamesTableViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 8/21/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NamesTableViewBaseController.h"


@protocol NameCardUpdateDelegate;


@interface NamesTableViewListController : NamesTableViewBaseController <SetupFetchedResultsControllerDelegate>



@property (nonatomic, strong) NSString *genderSelection;
@property (nonatomic, strong) NSString *namesOrder;

@property (assign, nonatomic) BOOL showCategories;
@property (nonatomic, strong) NSString *categorySelection;

@property (weak, nonatomic) id <NameCardUpdateDelegate> nameCardDelegate;

@end



@protocol NameCardUpdateDelegate <NSObject>

- (void)updateNameCard:(NSString *)name;

@end