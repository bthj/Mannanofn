//
//  CategoriesContainerController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 04/06/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "CategoriesContainerController.h"

@interface CategoriesContainerController ()

@end

@implementation CategoriesContainerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Ads
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    bannerView_.adUnitID = @"a1518d2dce38034";
    bannerView_.rootViewController = self;
    [self.adView addSubview:bannerView_];
    GADRequest *request = [GADRequest request];
    [bannerView_ loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
