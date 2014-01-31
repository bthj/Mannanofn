//
//  FilterChoicesTableViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 20/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "FilterChoicesViewController.h"

#import "SyllablesChoicesViewController.h"
#import "IcelandicLettersViewController.h"
#import "MinMaxPopularityViewController.h"
#import "InitialsViewController.h"
#import "SearchViewController.h"
#import "MannanofnGlobalStringConstants.h"


@interface FilterChoicesViewController () <SyllablesChoicesViewControllerDelegate, IcelandicLettersViewControllerDelegate>

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
    [self setIcelandicLetterCountDetail:[[NSUserDefaults standardUserDefaults] integerForKey:ICELANDIC_LETTER_COUNT_STORAGE_KEY]];
}

- (void)viewWillAppear:(BOOL)animated
{
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    
    [self setMinMaxDetail];
    [self setInitialsDetail];
    [self setSearchDetail];
    
    [self setSurnameDetail];
    
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
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:ICELANDIC_LETTER_COUNT_STORAGE_KEY];
    [self setIcelandicLetterCountDetail:0];
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:MIN_POPULARITY_STORAGE_KEY];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:MAX_POPULARITY_STORAGE_KEY];
    [self setMinMaxDetail];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:INITIAL_FIRST_STORAGE_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:INITIAL_SECOND_STORAGE_KEY];
    [self setInitialsDetail];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SEARCH_STRING_STORAGE_KEY];
    [self setSearchDetail];
    
    
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
        
    } else if( [[segue identifier] isEqualToString:@"ShowIcelandicLettersChoices"] ) {

        IcelandicLettersViewController *icelandicLettersController = (IcelandicLettersViewController *)[segue destinationViewController];
        icelandicLettersController.delegate = self;
    }
}


#pragma mark - Delegation

- (void)syllableCountChosen:(SyllablesChoicesViewController *)controller syllableCount:(NSInteger)syllableCount
{
    [self setSyllableCountDetail:syllableCount];
}

- (void)icelandicLetterCountChosen:(IcelandicLettersViewController *)controller icelandicLetterCount:(NSInteger)icelandicLetterCount
{
    [self setIcelandicLetterCountDetail:icelandicLetterCount];
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

- (void)setIcelandicLetterCountDetail:(NSInteger)icelandicLetterCount
{
    if( icelandicLetterCount > 0 ) {
        self.extendedLetterCountCell.detailTextLabel.text = [NSString stringWithFormat:@"%d stafir", icelandicLetterCount-1];
        self.extendedLetterCountCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGreen.png"];
    } else {
        self.extendedLetterCountCell.detailTextLabel.text = @"Allt";
        self.extendedLetterCountCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGray.png"];
    }
}


- (void)setMinMaxDetail
{
    if( [self areMinMaxFiltersSet] ) {
        NSInteger min = [MinMaxPopularityViewController getValueFromMinComponentStoredRow];
        NSInteger max = [MinMaxPopularityViewController getValueFromMaxComponentStoredRow];
        self.popularityFilterCell.detailTextLabel.text = [NSString stringWithFormat:@"%d - %d", min, max];
        self.popularityFilterCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGreen.png"];
    } else {
        self.popularityFilterCell.detailTextLabel.text = @"Allt";
        self.popularityFilterCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGray.png"];
    }
}

- (void)setInitialsDetail
{
    NSString *storedFirstInitial = [[NSUserDefaults standardUserDefaults] stringForKey:INITIAL_FIRST_STORAGE_KEY];
    NSString *storedSecondInitial = [[NSUserDefaults standardUserDefaults] stringForKey:INITIAL_SECOND_STORAGE_KEY];
    if( nil != storedFirstInitial || nil != storedSecondInitial ) {
        self.initialsCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGreen.png"];
        if( nil == storedFirstInitial ) storedFirstInitial = @"?";
        if( nil == storedSecondInitial ) storedSecondInitial = @"?";
        self.initialsCell.detailTextLabel.text = [NSString stringWithFormat:@"%@. %@.", storedFirstInitial, storedSecondInitial];
    } else {
        self.initialsCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGray.png"];
        self.initialsCell.detailTextLabel.text = @"Allt";
    }
}

- (void)setSearchDetail
{
    NSString *searchFilter = [[NSUserDefaults standardUserDefaults] stringForKey:SEARCH_STRING_STORAGE_KEY];
    if( searchFilter != nil & [searchFilter length] > 0 ) {
        self.searchCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGreen.png"];
        self.searchCell.detailTextLabel.text = searchFilter;
    } else {
        self.searchCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGray.png"];
        self.searchCell.detailTextLabel.text = @"Allt";
    }
}

- (void)setSurnameDetail
{
    self.surnameCell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:SURNAME_STORAGE_KEY];
}


- (BOOL)areFiltersSet {
    BOOL filtersAreSet = NO;
    if( [[NSUserDefaults standardUserDefaults] integerForKey:SYLLABLES_COUNT_STORAGE_KEY] > 0 ) {
        filtersAreSet = YES;
    }
    if( [[NSUserDefaults standardUserDefaults] integerForKey:ICELANDIC_LETTER_COUNT_STORAGE_KEY] > 0 ) {
        filtersAreSet = YES;
    }
    if( [self areMinMaxFiltersSet] ) {
        filtersAreSet = YES;
    }
    if( [InitialsViewController areInitialsFiltersSet] ) {
        filtersAreSet = YES;
    }
    if( [SearchViewController isSearchFilterSet] ) {
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


- (BOOL)areMinMaxFiltersSet
{
    if( [MinMaxPopularityViewController getMinComponentStoredRow] > 0 || [MinMaxPopularityViewController getMaxComponentStoredRow] > 0 ) {
        
        return YES;
    } else {
        return NO;
    }
}

@end
