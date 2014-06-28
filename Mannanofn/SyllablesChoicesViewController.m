//
//  SyllablesChoicesViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 20/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "SyllablesChoicesViewController.h"

#import "MannanofnGlobalStringConstants.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


@interface SyllablesChoicesViewController ()

@end

@implementation SyllablesChoicesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.syllableCount = [[NSUserDefaults standardUserDefaults] integerForKey:SYLLABLES_COUNT_STORAGE_KEY];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:@"Syllables Choices Screen"];
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if( self.syllableCount == indexPath.row ) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    self.syllableCount = indexPath.row;
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.syllableCount forKey:SYLLABLES_COUNT_STORAGE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [tableView reloadData];
    
    [[self delegate] syllableCountChosen:self syllableCount:self.syllableCount];
    
    // we'll call done to close in the above delegate method call - [self.navigationController popViewControllerAnimated:YES];
}

@end
