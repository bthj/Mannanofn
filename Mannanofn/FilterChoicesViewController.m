//
//  FilterChoicesTableViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 20/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "FilterChoicesViewController.h"

#import "SyllablesChoicesViewController.h"
#import "MannanofnGlobalStringConstants.h"


@interface FilterChoicesViewController () <SyllablesChoicesViewControllerDelegate>

@end

@implementation FilterChoicesViewController

/***
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
***/

- (void)viewDidLoad
{
    [super viewDidLoad];


    [self setSyllableCountDetail:[[NSUserDefaults standardUserDefaults] integerForKey:SYLLABLES_COUNT_STORAGE_KEY]];
}


- (IBAction)done:(id)sender {
    [[self delegate] filterChoicesTableViewControllerDidFinish:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if( [[segue identifier] isEqualToString:@"ShowSyllablesChoices"] ) {
        SyllablesChoicesViewController *syllablesChoices = (SyllablesChoicesViewController *)[segue destinationViewController];
        syllablesChoices.delegate = self;
    }
}


#pragma mark - Delegation

- (void)syllableCountChosen:(SyllablesChoicesViewController *)controller syllableCount:(NSInteger)syllableCount
{
    [self setSyllableCountDetail:syllableCount];
}



- (void)setSyllableCountDetail:(NSInteger)syllableCount
{
    if( syllableCount > 0 ) {
        self.syllableCountCell.detailTextLabel.text = [NSString stringWithFormat:@"%d atkvæði", syllableCount];
    } else {
        self.syllableCountCell.detailTextLabel.text = @"Allt";
    }
}


@end
