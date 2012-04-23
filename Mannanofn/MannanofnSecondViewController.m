//
//  MannanofnSecondViewController.m
//  Mannanofn
//
//  Created by Bjorn Thor Jonsson on 4/23/12.
//  Copyright (c) 2012 Síminn. All rights reserved.
//

#import "MannanofnSecondViewController.h"

@interface MannanofnSecondViewController ()

@end

@implementation MannanofnSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
