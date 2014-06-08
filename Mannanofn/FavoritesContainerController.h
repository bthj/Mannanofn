//
//  FavoritesContainerController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 04/06/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GAITrackedViewController.h"
#import "GADBannerView.h"


@interface FavoritesContainerController : UIViewController {
    
    GADBannerView *bannerView_;
}


@property (weak, nonatomic) IBOutlet UIView *adView;

@property (weak, nonatomic) IBOutlet UIButton *adCloseButton;
- (IBAction)closeAd:(id)sender;



@end
