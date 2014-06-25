//
//  TransactionObserver.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 12/06/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "TransactionObserver.h"

#import "MannanofnGlobalStringConstants.h"


@implementation TransactionObserver {
    
    MBProgressHUD *hud;
}

- (id)init {
    if ( self = [super init] ) {
        
        self.filtersPurchased = [self areFiltersPurchased];
    }
    return self;
}


- (BOOL)areFiltersPurchased {

    // TODO: Validate the receipt with something like
    // https://github.com/rmaddy/VerifyStoreReceiptiOS
    // or
    // https://github.com/rjstelling/ReceiptKit !
    // see also https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Chapters/DeliverProduct.html
    // https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html#//apple_ref/doc/uid/TP40010573-CH104-SW1
    // for now, let's be prone to cracking and store and read purchase info in NSUserDefaults
    // without receipt validation.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:ENABLE_FILTERS_KEY];
}

- (void)markFiltersAsPurchased {
    
#if USE_ICLOUD_STORAGE
    NSUbiquitousKeyValueStore *storage = [NSUbiquitousKeyValueStore defaultStore];
#else
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
#endif
    
    [storage setBool:YES forKey:ENABLE_FILTERS_KEY];
    
    [storage synchronize];
    
    self.filtersPurchased = YES;
}



#pragma mark - SKPaymentTransactionObserver protocol method

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                // Call the appropriate custom method.
            case SKPaymentTransactionStatePurchasing:
                [self showInfoAboutPuchaseInProgress:transaction];
                break;
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}


- (void)showInfoAboutPuchaseInProgress:(SKPaymentTransaction *)transaction {
    
    hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    hud.labelText = @"Afgreiði...";
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    [self markFiltersAsPurchased];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    
    [self showSuccessInfo];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Villa :("
                                                      message:@"Kaupin gengu ekki eftir.  Vinsamlegast reyndu aftur"
                                                     delegate:nil
                                            cancelButtonTitle:@"Áfram"
                                            otherButtonTitles:nil];
    [message show];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
 
    
}




- (void)showSuccessInfo {
    
	hud = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
	[[[UIApplication sharedApplication] keyWindow] addSubview:hud];
    
	// The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
	// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
	hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    
	// Set custom view mode
	hud.mode = MBProgressHUDModeCustomView;
    
	hud.delegate = self;
	hud.labelText = @"Þökkum viðskiptin";
    
	[hud show:YES];
	[hud hide:YES afterDelay:3];
}


@end
