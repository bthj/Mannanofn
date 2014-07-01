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

#import "ShopViewController.h"
#import "MannanofnAppDelegate.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


@interface FilterChoicesViewController () <SyllablesChoicesViewControllerDelegate, IcelandicLettersViewControllerDelegate, MinMaxPopularityViewControllerDelegate, InitialsViewControllerDelegate, SearchViewControllerDelegate, ShopViewControllerDelegate>


@property (nonatomic, strong) ShopViewController *shopController;

@property (nonatomic, strong) MannanofnAppDelegate *appDelegate;

@end

@implementation FilterChoicesViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shopController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShopController"];
    self.shopController.delegate = self;


    [self setSyllableCountDetail:[[NSUserDefaults standardUserDefaults] integerForKey:SYLLABLES_COUNT_STORAGE_KEY]];
    [self setIcelandicLetterCountDetail:[[NSUserDefaults standardUserDefaults] integerForKey:ICELANDIC_LETTER_COUNT_STORAGE_KEY]];
    
    
    self.appDelegate = (MannanofnAppDelegate *)[[UIApplication sharedApplication] delegate];
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
    
    [self.adSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ADS_ON]];
    //[self.adSwitch setOn:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:@"Filter Choices Screen"];
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createAppView] build]];
}


- (IBAction)done:(id)sender {
    [[self delegate] filterChoicesTableViewControllerDidFinish:self];
}

- (IBAction)switchAds:(UISwitch *)sender {
    
#if TARGET_IPHONE_SIMULATOR
    
    BOOL hasFilterAddon = YES;
    
#else
    
    BOOL hasFilterAddon = NO;
    
#endif
    
    if( hasFilterAddon == NO ) {
        
        hasFilterAddon = self.appDelegate.transactionObserver.filtersPurchased;
    }
    
    if( hasFilterAddon ) {

        [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:ADS_ON];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } else {
        
        [self showStore];
    }
    
    
    [[[GAI sharedInstance] defaultTracker]
     send:[[GAIDictionaryBuilder createEventWithCategory:@"uiAction"
                                                  action:@"buttonPress"
                                                   label:@"Switch Ads"
                                                   value:[NSNumber numberWithBool:sender.on]] build]];
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
        [self done:nil];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if( indexPath.section == 2 && indexPath.row == 1 ) {
        
        [self showGuide];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    if( indexPath.section == 2 && indexPath.row == 1 ) {
        
        [self showGuide];
    }
}


- (void)showGuide {

    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:FIRST_RUN_GUIDE_BEEN_DISMISSED_FOR_VERSION];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[self delegate] filterChoicesTableViewControllerDidFinish:self];
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
    
    // self.clearFiltersCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGreen.png"];
    self.clearFiltersCell.imageView.image = [UIImage imageNamed:@"ios-check.png"];
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
        
    } else if( [[segue identifier] isEqualToString:@"ShowMinMaxPopularityChoices"] ) {
        
        MinMaxPopularityViewController *minMaxPopularityController = (MinMaxPopularityViewController *)[segue destinationViewController];
        minMaxPopularityController.delegate = self;
        
    } else if( [[segue identifier] isEqualToString:@"ShowInitialsChoices"] ) {
        
        InitialsViewController *initialsController = (InitialsViewController *)[segue destinationViewController];
        initialsController.delegate = self;
        
    } else if( [[segue identifier] isEqualToString:@"ShowSearchForm"] ) {
        
        SearchViewController *searchController = (SearchViewController *)[segue destinationViewController];
        searchController.delegate = self;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
#if TARGET_IPHONE_SIMULATOR
    
    BOOL hasFilterAddon = YES;
    
#else
    
    BOOL hasFilterAddon = NO;
    
#endif
    
    if( hasFilterAddon == NO ) {
        
        hasFilterAddon = self.appDelegate.transactionObserver.filtersPurchased;
    }
    
    BOOL shouldPerformSegue = NO;
    
    if( hasFilterAddon
        || [identifier isEqual:@"AboutAppSegue"]
        || [identifier isEqual:@"AboutAppSegueDisclosure"] ) {
        
        shouldPerformSegue = YES;
    } else {
        
        [self showStore];
    }
    return shouldPerformSegue;
}


#pragma mark - FilterChoicesTableViewControllerDelegate

- (void)shopViewControllerDidCancel:(ShopViewController *)controller {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)shopViewControllerDidPurchase:(ShopViewController *)controller {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Delegation

- (void)syllableCountChosen:(SyllablesChoicesViewController *)controller syllableCount:(NSInteger)syllableCount
{
    [self setSyllableCountDetail:syllableCount];
    [self done:nil];
}

- (void)icelandicLetterCountChosen:(IcelandicLettersViewController *)controller icelandicLetterCount:(NSInteger)icelandicLetterCount
{
    [self setIcelandicLetterCountDetail:icelandicLetterCount];
    [self done:nil];
}

- (void)minMaxApplied:(MinMaxPopularityViewController *)controller {
    
    [self done:nil];
}

- (void)initialsApplied:(InitialsViewController *)controller {
    
    [self done:nil];
}

- (void)searchCriteriaApplied:(SearchViewController *)controller {
    
    [self done:nil];
}



- (void)showStore {
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.shopController];
    
    [self presentViewController:navigationController animated:YES completion: nil];
}



- (void)setSyllableCountDetail:(NSInteger)syllableCount
{
    if( syllableCount > 0 ) {
        self.syllableCountCell.detailTextLabel.text = [NSString stringWithFormat:@"%d atkvæði", syllableCount];
        // self.syllableCountCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGreen.png"];
        self.syllableCountCell.imageView.image = [UIImage imageNamed:@"ios-check.png"];

    } else {
        self.syllableCountCell.detailTextLabel.text = @"Allt";
        // self.syllableCountCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGray.png"];
        self.syllableCountCell.imageView.image = [UIImage imageNamed:@"ios-nocheck.png"];
    }
}

- (void)setIcelandicLetterCountDetail:(NSInteger)icelandicLetterCount
{
    if( icelandicLetterCount > 0 ) {
        NSInteger displayedLetterCount = icelandicLetterCount-1;
        NSString *letterCountSuffix;
        if( displayedLetterCount == 1 ) {
            letterCountSuffix = @"stafur";
        } else {
            letterCountSuffix = @"stafir";
        }
        self.extendedLetterCountCell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", displayedLetterCount, letterCountSuffix];
        // self.extendedLetterCountCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGreen.png"];
        self.extendedLetterCountCell.imageView.image = [UIImage imageNamed:@"ios-check.png"];
    } else {
        self.extendedLetterCountCell.detailTextLabel.text = @"Allt";
        // self.extendedLetterCountCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGray.png"];
        self.extendedLetterCountCell.imageView.image = [UIImage imageNamed:@"ios-nocheck.png"];
    }
}


- (void)setMinMaxDetail
{
    if( [self areMinMaxFiltersSet] ) {
        NSInteger min = [MinMaxPopularityViewController getValueFromMinComponentStoredRow];
        NSInteger max = [MinMaxPopularityViewController getValueFromMaxComponentStoredRow];
        self.popularityFilterCell.detailTextLabel.text = [NSString stringWithFormat:@"%d - %d", min, max];
        // self.popularityFilterCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGreen.png"];
        self.popularityFilterCell.imageView.image = [UIImage imageNamed:@"ios-check.png"];
    } else {
        self.popularityFilterCell.detailTextLabel.text = @"Allt";
        // self.popularityFilterCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGray.png"];
        self.popularityFilterCell.imageView.image = [UIImage imageNamed:@"ios-nocheck.png"];
    }
}

- (void)setInitialsDetail
{
    NSString *storedFirstInitial = [[NSUserDefaults standardUserDefaults] stringForKey:INITIAL_FIRST_STORAGE_KEY];
    NSString *storedSecondInitial = [[NSUserDefaults standardUserDefaults] stringForKey:INITIAL_SECOND_STORAGE_KEY];
    if( nil != storedFirstInitial || nil != storedSecondInitial ) {
        // self.initialsCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGreen.png"];
        self.initialsCell.imageView.image = [UIImage imageNamed:@"ios-check.png"];
        if( nil == storedFirstInitial ) storedFirstInitial = @"?";
        if( nil == storedSecondInitial ) storedSecondInitial = @"?";
        self.initialsCell.detailTextLabel.text = [NSString stringWithFormat:@"%@. %@.", storedFirstInitial, storedSecondInitial];
    } else {
        // self.initialsCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGray.png"];
        self.initialsCell.imageView.image = [UIImage imageNamed:@"ios-nocheck.png"];
        self.initialsCell.detailTextLabel.text = @"Allt";
    }
}

- (void)setSearchDetail
{
    NSString *searchFilter = [[NSUserDefaults standardUserDefaults] stringForKey:SEARCH_STRING_STORAGE_KEY];
    if( searchFilter != nil & [searchFilter length] > 0 ) {
        // self.searchCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGreen.png"];
        self.searchCell.imageView.image = [UIImage imageNamed:@"ios-check.png"];
        self.searchCell.detailTextLabel.text = searchFilter;
    } else {
        // self.searchCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGray.png"];
        self.searchCell.imageView.image = [UIImage imageNamed:@"ios-nocheck.png"];
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
        // self.clearFiltersCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGray.png"];
        self.clearFiltersCell.imageView.image = [UIImage imageNamed:@"ios-nocheck.png"];
    } else {
        // self.clearFiltersCell.imageView.image = [UIImage imageNamed:@"tableViewBulletGreen.png"];
        self.clearFiltersCell.imageView.image = [UIImage imageNamed:@"ios-check.png"];
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
