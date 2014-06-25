//
//  ShopViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 10/06/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>


@protocol ShopViewControllerDelegate;



@interface ShopViewController : UIViewController

@property (weak, nonatomic) id <ShopViewControllerDelegate> delegate;


- (IBAction)cancel:(id)sender;


- (IBAction)restorePurchases:(id)sender;

- (IBAction)purchase:(id)sender;


@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnRestorePurchases;
@property (weak, nonatomic) IBOutlet UIButton *btnPurchase;


@end



@protocol ShopViewControllerDelegate <NSObject>

- (void)shopViewControllerDidCancel:(ShopViewController *)controller;
- (void)shopViewControllerDidPurchase:(ShopViewController *)controller;

@end