//
//  NamesContainerViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 10/23/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#import "NamesContainerViewController.h"

#import "NamesTableViewController.h"
#import "MannanofnGlobalStringConstants.h"

@interface NamesContainerViewController ()

@end

@implementation NamesContainerViewController



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [[segue identifier] isEqualToString:@"NamesTableEmbedSegue"] ) {
        NamesTableViewController *namesTable = (NamesTableViewController *)[segue destinationViewController];
        
        namesTable.namesOrder = self.namesOrder;
        
        switch (self.genderSelection.selectedSegmentIndex) {
            case 0:
                namesTable.genderSelection = GENDER_MALE;
                break;
            case 1:
                namesTable.genderSelection = GENDER_FEMALE;
                break;
            default:
                break;
        }
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
