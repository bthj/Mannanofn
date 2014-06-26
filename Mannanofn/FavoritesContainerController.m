//
//  FavoritesContainerController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 04/06/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "FavoritesContainerController.h"

#import "MannanofnGlobalStringConstants.h"

#import "ShopViewController.h"
#import "MannanofnAppDelegate.h"


@interface FavoritesContainerController () <ShopViewControllerDelegate>

@property (nonatomic, strong) ShopViewController *shopController;
@property (nonatomic, strong) MannanofnAppDelegate *appDelegate;

@end



@implementation FavoritesContainerController

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
    if( [[NSUserDefaults standardUserDefaults] boolForKey:ADS_ON] ) {
     
        bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        bannerView_.adUnitID = @"a1518d2dce38034";
        bannerView_.rootViewController = self;
        [self.adView addSubview:bannerView_];
        GADRequest *request = [GADRequest request];
        [bannerView_ loadRequest:request];
        
        [self.adView bringSubviewToFront:self.adCloseButton];
    }
    
    
    // Shop
    
    self.shopController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShopController"];
    self.shopController.delegate = self;
    
    self.appDelegate = (MannanofnAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactToFilterPurchase:) name:NOTIFICATION_PURCHASED_FILTERS object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.adView.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey:ADS_ON];
}

- (void)reactToFilterPurchase:(NSNotification *)notifiaction {
    
    self.adView.hidden = YES;
}

- (IBAction)closeAd:(id)sender {
    
    BOOL hasFilterAddon = self.appDelegate.transactionObserver.filtersPurchased;
    
    if( hasFilterAddon ) {
        
        self.adView.hidden = YES;
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ADS_ON];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } else {
        
        // show store
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.shopController];
        
        [self presentViewController:navigationController animated:YES completion: nil];
        
    }
}


#pragma mark - ShopViewControllerDelegate

- (void)shopViewControllerDidCancel:(ShopViewController *)controller {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)shopViewControllerDidPurchase:(ShopViewController *)controller {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
