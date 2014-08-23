//
//  NameInfoViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/4/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoritesDatabaseUtility.h"
#import "GAITrackedViewController.h"
#import "GADBannerView.h"


#import "CollectionViewDataFetchDelegate.h"

@protocol CollectionViewDataFetchDelegate;



@interface NameInfoViewController : GAITrackedViewController <SetFavoritesDatabaseDelegate> {
    
    GADBannerView *bannerView_;
}


@property (weak, nonatomic) id <CollectionViewDataFetchDelegate> delegate;


@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *descriptionLegend;
@property (nonatomic, strong) NSString *origin;
@property (nonatomic, strong) NSString *originLegend;
@property (nonatomic, strong) NSNumber *countAsFirstName;
@property (nonatomic, strong) NSNumber *countAsSecondName;


@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *originLabel;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLegendLabel;
@property (weak, nonatomic) IBOutlet UILabel *originLegendLabel;

@property (weak, nonatomic) IBOutlet UILabel *countAsFirstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countAsSecondNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *addDescriptionButton;

@property (weak, nonatomic) IBOutlet UIButton *toggleFavoriteButton;

@property (weak, nonatomic) IBOutlet UIView *adView;

- (IBAction)toggleFavorite:(id)sender;


- (IBAction)mailDescription:(id)sender;

- (IBAction)openAdUrl:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *adCloseButton;
- (IBAction)closeAd:(id)sender;


@end
