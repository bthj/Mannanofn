//
//  NameInfoViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/4/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import "NameInfoViewController.h"
#import "GAI.h"


@interface NameInfoViewController ()

@property (strong, nonatomic) FavoritesDatabaseUtility *favoritesDatabaseUtility;

@end

@implementation NameInfoViewController

- (void)setFavoritesDatabase:(UIManagedDocument *)favoritesDatabase
{
    // we won't be setting favoritesDatabase here locally as property as we rely solely on FavoritesDatabaseUtility,
    // look up in the db when we know via this delegate method that it's been set up
    [self lookupAndUpdateFavoriteButtonImage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.nameLabel.text = self.name;
    self.descriptionLabel.text = self.description;
    
    if( [self.description length] > 0 ) {
        self.descriptionLegendLabel.hidden = NO;
        self.addDescriptionButton.hidden = YES;
    } else {
        self.descriptionLegendLabel.hidden = YES;
        self.addDescriptionButton.hidden = NO;
    }
    
    self.originLabel.text = self.origin;
    if( [self.origin length] > 0 ) {
        self.originLegendLabel.hidden = NO;
    } else {
        self.originLegendLabel.hidden = YES;
    }
    
    if( [self.descriptionLegend length] > 0 ) {
        [self.descriptionLegendLabel setText:self.descriptionLegend];
    }
    if( [self.originLegend length] > 0 ) {
        [self.originLegendLabel setText:self.originLegend];
    }
    
    self.countAsFirstNameLabel.text = [self.countAsFirstName stringValue];
    self.countAsSecondNameLabel.text = [self.countAsSecondName stringValue];
    
    self.favoritesDatabaseUtility = [[FavoritesDatabaseUtility alloc] initFavoritesDatabaseForView: self.view];
    self.favoritesDatabaseUtility.setFavoritesDatabaseDelegate = self;
    
    
    // Ads
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    bannerView_.adUnitID = @"a1518d2dce38034";
    bannerView_.rootViewController = self;
    [self.adView addSubview:bannerView_];
    GADRequest *request = [GADRequest request];
    request.testDevices = [NSArray arrayWithObjects:@"GAD_SIMULATOR_ID", nil];
    [bannerView_ loadRequest:request];
}
- (void)viewWillAppear:(BOOL)animated
{
    self.trackedViewName = @"Name Info Screen";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateFavoritesButtonImageToActive
{
    [self.toggleFavoriteButton setImage:[UIImage imageNamed:@"heart_nametag"] forState:UIControlStateNormal];
}
- (void)updateFavoritesButtonImageToInctive
{
    [self.toggleFavoriteButton setImage:[UIImage imageNamed:@"heart_nametag_disabled"] forState:UIControlStateNormal];
}
- (void)updateFavoriteButtonImageToState:(BOOL)active
{
    if( active ) {
        [self updateFavoritesButtonImageToActive];
    } else {
        [self updateFavoritesButtonImageToInctive];
    }
    
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"uiAction"
                                                      withAction:@"buttonPress"
                                                       withLabel:@"Toggle favorite in Name Info Screen"
                                                       withValue:[NSNumber numberWithBool:active]];
}
- (void)lookupAndUpdateFavoriteButtonImage{
    
    [self updateFavoriteButtonImageToState:[self.favoritesDatabaseUtility isInFavorites:self.name]];
}
- (IBAction)toggleFavorite:(id)sender {
    
    [self updateFavoriteButtonImageToState:[self.favoritesDatabaseUtility toggleFavoriteForName:self.name gender:self.gender]];
}

- (IBAction)mailDescription:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[@"mailto:nemur@nemur.net?subject=Nefna: Athugasemd við merkingu nafnsins " stringByAppendingString:self.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

- (IBAction)openAdUrl:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.nemur.net"]];
}

@end
