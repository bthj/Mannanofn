//
//  ShopViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 10/06/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "ShopViewController.h"

#import "MBProgressHUD.h"
#import "MannanofnGlobalStringConstants.h"
#import "MannanofnAppDelegate.h"


@interface ShopViewController () <SKProductsRequestDelegate>

@property (nonatomic, strong) SKProduct *filterProduct;

@property (nonatomic, strong) MannanofnAppDelegate *appDelegate;

@end



@implementation ShopViewController

@synthesize delegate = _delegate;


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
    // Do any additional setup after loading the view.
    
    self.btnPurchase.hidden = YES;
    self.btnRestorePurchases.hidden = YES;
    self.priceLabel.hidden = YES;
    
    self.appDelegate = (MannanofnAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Sæki prísinn...";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [self validateProductIdentifiers:[self getProductIdentifiers]];
        
        dispatch_async(dispatch_get_main_queue(), ^{

        });
    });
    
    
    self.screenName = @"Shop Screen";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)cancel:(id)sender {
    
    [[self delegate] shopViewControllerDidCancel:self];
}

- (IBAction)restorePurchases:(id)sender {
    
    /*
    SKReceiptRefreshRequest *request = [[SKReceiptRefreshRequest alloc] init];
    request.delegate = self;
    [request start];
     */
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
    [[self delegate] shopViewControllerDidPurchase:self];
    
    [self.appDelegate.transactionObserver showInfoAboutPuchaseInProgress:nil];
}

- (IBAction)purchase:(id)sender {
    
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:self.filterProduct];
    // payment.quantity = 1;
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
    [[self delegate] shopViewControllerDidPurchase:self];
}



#pragma mark - StoreKit communication
- (NSArray *)getProductIdentifiers {
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"product_ids"
                                         withExtension:@"plist"];
    return [NSArray arrayWithContentsOfURL:url];
}

// as in https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Chapters/ShowUI.html#//apple_ref/doc/uid/TP40008267-CH3-SW5
- (void)validateProductIdentifiers:(NSArray *)productIdentifiers
{
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    productsRequest.delegate = self;
    [productsRequest start];
}


#pragma mark - UITextFieldDelegate protocol method
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    for( NSString *invalidIdentifier in response.invalidProductIdentifiers ) {
        
        NSLog(@"Invalid product identifier: %@", invalidIdentifier);
    }
    
    if( [response.products count] > 0 ) {
        
        for( SKProduct *oneProduct in response.products ) {
            
            if( [oneProduct.productIdentifier isEqualToString:PRODUCT_IDENTIFIER__FILTERS] ) {
         
                [self enableFilterPackageForPurchase:[response.products objectAtIndex:0]];
                break;
            }
        }
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"SKRequest error: %@", error);
}


- (void)enableFilterPackageForPurchase:(SKProduct *)filterProduct {
    
    self.filterProduct = filterProduct;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:filterProduct.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:filterProduct.price];
    
    self.priceLabel.text = formattedPrice;
    
    self.btnPurchase.hidden = NO;
    self.btnRestorePurchases.hidden = NO;
    self.priceLabel.hidden = NO;
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


@end
