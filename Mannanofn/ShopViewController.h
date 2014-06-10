//
//  ShopViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 10/06/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ShopViewControllerDelegate;



@interface ShopViewController : UIViewController

@property (weak, nonatomic) id <ShopViewControllerDelegate> delegate;


- (IBAction)cancel:(id)sender;


- (IBAction)restorePurchases:(id)sender;

- (IBAction)purchase:(id)sender;


@end



@protocol ShopViewControllerDelegate <NSObject>

- (void)shopViewControllerDidCancel:(ShopViewController *)controller;

@end