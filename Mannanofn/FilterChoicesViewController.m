//
//  FilterChoicesTableViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 20/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "FilterChoicesViewController.h"

#import "SyllablesChoicesViewController.h"
#import "MinMaxPopularityViewController.h"
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

- (void)viewWillAppear:(BOOL)animated
{
    [self setMinMaxDetail];
    
    [self setClearFiltersCellStatus];
}


- (IBAction)done:(id)sender {
    [[self delegate] filterChoicesTableViewControllerDidFinish:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 0 && indexPath.row == 0 ) {
        [self clearFilters];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


- (void)clearFilters
{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:SYLLABLES_COUNT_STORAGE_KEY];
    [self setSyllableCountDetail:0];
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:MIN_POPULARITY_STORAGE_KEY];
    [[NSUserDefaults standardUserDefaults] setInteger:MAX_TOTAL_NUMBER_OF_NAMES forKey:MAX_POPULARITY_STORAGE_KEY];
    [self setMinMaxDetail];
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.clearFiltersCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGreen.png"];
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
        self.syllableCountCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGreen.png"];

    } else {
        self.syllableCountCell.detailTextLabel.text = @"Allt";
        self.syllableCountCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGray.png"];
    }
}

- (void)setMinMaxDetail
{
    NSInteger min = [[NSUserDefaults standardUserDefaults] integerForKey:MIN_POPULARITY_STORAGE_KEY];
    NSInteger max = [[NSUserDefaults standardUserDefaults] integerForKey:MAX_POPULARITY_STORAGE_KEY];
    
    if( min > 0 || max < MAX_TOTAL_NUMBER_OF_NAMES ) {
        self.popularityFilterCell.detailTextLabel.text = [NSString stringWithFormat:@"%d - %d", min, max];
        self.popularityFilterCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGreen.png"];
    } else {
        self.popularityFilterCell.detailTextLabel.text = @"Allt";
        self.popularityFilterCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGray.png"];
    }
}


- (BOOL)areFiltersSet {
    BOOL filtersAreSet = NO;
    if( [[NSUserDefaults standardUserDefaults] integerForKey:SYLLABLES_COUNT_STORAGE_KEY] > 0 ) {
        filtersAreSet = YES;
    }
    if( [MinMaxPopularityViewController getRowFromStoredValueInComponent:0] > 0 || [MinMaxPopularityViewController getRowFromStoredValueInComponent:1] > 0 ) {
        filtersAreSet = YES;
    }
    return filtersAreSet;
}

- (void)setClearFiltersCellStatus
{
    if( [self areFiltersSet] ) {
        self.clearFiltersCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGray.png"];
    } else {
        self.clearFiltersCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGreen.png"];
    }
}


@end
