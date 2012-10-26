//
//  AlphabeticalViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 10/23/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#import "NamesOrderViewController.h"
#import "MannanofnGlobalStringConstants.h"
#import "NamesContainerViewController.h"

@interface NamesOrderViewController ()

@end

@implementation NamesOrderViewController



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NamesContainerViewController *namesContainer = (NamesContainerViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
    
    if( [[segue identifier] isEqualToString:@"AlphabeticalEmbedSegue"] ) {
        
        namesContainer.namesOrder = ORDER_BY_NAME;
        
    } else if( [[segue identifier] isEqualToString:@"PopularityEmbedSegue"] ) {
        
        namesContainer.namesOrder = ORDER_BY_FIRST_NAME_POPULARITY;
        
    } else if( [[segue identifier] isEqualToString:@"CategoryEmbedSegue"] ) {
        
        
    }
}



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

@end
