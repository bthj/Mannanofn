//
//  ShopViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 10/06/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "ShopViewController.h"

@interface ShopViewController ()

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
@end
