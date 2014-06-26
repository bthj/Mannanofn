//
//  TransactionObserver.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 12/06/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "MBProgressHUD.h"

@interface TransactionObserver : NSObject <SKPaymentTransactionObserver, MBProgressHUDDelegate>

@property (nonatomic, assign) BOOL filtersPurchased;

- (void)showInfoAboutPuchaseInProgress:(SKPaymentTransaction *)transaction;

@end
