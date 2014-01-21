//
//  SyllablesChoicesViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 20/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "SyllablesChoicesViewController.h"

#import "MannanofnGlobalStringConstants.h"

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.syllableCount = [[NSUserDefaults standardUserDefaults] integerForKey:SYLLABLES_COUNT_STORAGE_KEY];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.syllableCount = indexPath.row;
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.syllableCount forKey:SYLLABLES_COUNT_STORAGE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [tableView reloadData];
    
    [[self delegate] syllableCountChosen:self syllableCount:self.syllableCount];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
