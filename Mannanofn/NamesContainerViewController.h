//
//  NamesContainerViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 10/23/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NamesTableViewListController.h"
#import "FavoritesDatabaseUtility.h"

#import "GAITrackedViewController.h"
#import "GADBannerView.h"

@interface NamesContainerViewController : UIViewController <NameCardUpdateDelegate, SetFavoritesDatabaseDelegate> {
    
    GADBannerView *bannerView_;
}

@property (assign, nonatomic) BOOL showCategories;
@property (nonatomic, strong) NSString *namesOrder;
@property (nonatomic, strong) NSString *categorySelection;
@property (nonatomic, strong) NSString *originSelection;
@property (nonatomic, strong) NSString *navigationItemTitle;


@property (weak, nonatomic) IBOutlet UIView *navigationView;


@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSelection;
@property (weak, nonatomic) IBOutlet UISegmentedControl *namePosition;
- (IBAction)selectNamePosition:(id)sender;
- (IBAction)selectGender:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *nameCard;
@property (weak, nonatomic) IBOutlet UILabel *nameOnCard;

@property (weak, nonatomic) IBOutlet UIButton *toggleFavoriteButton;
- (IBAction)toggleFavorite:(id)sender;

- (IBAction)clearNameCardAction:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *tableContainer;

@property (weak, nonatomic) IBOutlet UIImageView *firstRunGuide;


@property (weak, nonatomic) IBOutlet UIView *adView;


@end
