//
//  IcelandicLettersViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 25/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "IcelandicLettersViewController.h"

#import "MannanofnGlobalStringConstants.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


@interface IcelandicLettersViewController ()

@end

@implementation IcelandicLettersViewController

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

    self.icelandicLetterCount = [[NSUserDefaults standardUserDefaults] integerForKey:ICELANDIC_LETTER_COUNT_STORAGE_KEY];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:@"Icelandic Letters Screen"];
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
    
    if( self.icelandicLetterCount == indexPath.row ) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.icelandicLetterCount = indexPath.row;
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.icelandicLetterCount forKey:ICELANDIC_LETTER_COUNT_STORAGE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [tableView reloadData];
    
    [[self delegate] icelandicLetterCountChosen:self icelandicLetterCount:self.icelandicLetterCount];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
