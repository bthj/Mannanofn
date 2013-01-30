//
//  NamesContainerViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 10/23/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NamesTableViewListController.h"

@interface NamesContainerViewController : UIViewController <NameCardUpdateDelegate>

@property (assign, nonatomic) BOOL showCategories;
@property (nonatomic, strong) NSString *namesOrder;


@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSelection;
- (IBAction)selectGender:(id)sender;


@property (weak, nonatomic) IBOutlet UISegmentedControl *namePosition;


@property (weak, nonatomic) IBOutlet UIView *nameCard;
@property (weak, nonatomic) IBOutlet UILabel *nameOnCard;


@property (weak, nonatomic) IBOutlet UIView *tableContainer;



@end
