//
//  ShopViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 10/06/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "ShopViewController.h"

#import "MBProgressHUD.h"



@interface ShopViewController () <SKProductsRequestDelegate>

@property (nonatomic, strong) NSArray *products;

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
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Sæki prísinn...";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [self validateProductIdentifiers:[self getProductIdentifiers]];
        
        dispatch_async(dispatch_get_main_queue(), ^{

        });
    });
    
    
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
}

- (IBAction)purchase:(id)sender {
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
    
    self.products = response.products;
    
    for( NSString *invalidIdentifier in response.invalidProductIdentifiers ) {
        
        NSLog(@"Invalid product identifier: %@", invalidIdentifier);
    }
    
    if( [response.products count] > 0 ) {
        
        [self displayFilterPackagePrice:[response.products objectAtIndex:0]];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"SKRequest error: %@", error);
}


- (void)displayFilterPackagePrice:(SKProduct *)filterProduct {
    
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
