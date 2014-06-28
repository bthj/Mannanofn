//
//  NamesContainerViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 10/23/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#import "NamesContainerViewController.h"

#import "MannanofnGlobalStringConstants.h"
#import "Favorite+Create.h"
#import "FilterChoicesViewController.h"
#import "MinMaxPopularityViewController.h"
#import "InitialsViewController.h"
#import "SearchViewController.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"

#import "ShopViewController.h"
#import "MannanofnAppDelegate.h"


@interface NamesContainerViewController () <FilterChoicesTableViewControllerDelegate, ShopViewControllerDelegate>

@property (nonatomic, strong) NamesTableViewListController *namesTableView;
@property (strong, nonatomic) FavoritesDatabaseUtility *favoritesDatabaseUtility;
@property (nonatomic, strong) UIManagedDocument *favoritesDatabase;
@property (nonatomic, strong) NSString *currentNameLookedUpInFavorites;

@property (nonatomic, strong) ShopViewController *shopController;
@property (nonatomic, strong) MannanofnAppDelegate *appDelegate;

@property (nonatomic, strong) NSString *currentBuildVersion;

@end



@implementation NamesContainerViewController

@synthesize favoritesDatabase = _favoritesDatabase;


- (void)filterChoicesTableViewControllerDidCancel:(FilterChoicesViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)filterChoicesTableViewControllerDidFinish:(FilterChoicesViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    [self.namesTableView loadFilters];
    [self.namesTableView fetchResults];
}


- (void)setFavoritesDatabase:(UIManagedDocument *)favoritesDatabase
{
    if( _favoritesDatabase != favoritesDatabase ) {
        _favoritesDatabase = favoritesDatabase;
    }
    if( favoritesDatabase ) {
        [self.toggleFavoriteButton setEnabled:YES];
    }
}

- (void)imageTaped:(UIGestureRecognizer *)gestureRecognizer {
    self.firstRunGuide.hidden = YES;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.currentBuildVersion forKey:FIRST_RUN_GUIDE_BEEN_DISMISSED_FOR_VERSION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self clearNameCard];
    
    //self.tableContainer.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableViewBackground"]];
    
    self.tableContainer.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"tableViewBackgroundBlue"]];
    
    [self.toggleFavoriteButton setEnabled:NO];  // to be disabled until favorites db is ready
    self.favoritesDatabaseUtility = [[FavoritesDatabaseUtility alloc] initFavoritesDatabaseForView:self.view];
    self.favoritesDatabaseUtility.setFavoritesDatabaseDelegate = self;
    
    
    // Ads
    if( [[NSUserDefaults standardUserDefaults] boolForKey:ADS_ON] ) {
        
        bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        bannerView_.adUnitID = @"a1518d2dce38034";
        bannerView_.rootViewController = self;
        [self.adView addSubview:bannerView_];
        GADRequest *request = [GADRequest request];
        //    request.testDevices = [NSArray arrayWithObjects:@"GAD_SIMULATOR_ID", nil];
        [bannerView_ loadRequest:request];
        
        [self.adView bringSubviewToFront:self.adCloseButton];
    }
    
    
    // Shop
    
    self.shopController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShopController"];
    self.shopController.delegate = self;
    
    self.appDelegate = (MannanofnAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactToFilterPurchase:) name:NOTIFICATION_PURCHASED_FILTERS object:nil];
    
    
    self.currentBuildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (void)reactToFilterPurchase:(NSNotification *)notifiaction {
    
    self.adView.hidden = YES;
}

- (IBAction)closeAd:(id)sender {
    
    BOOL hasFilterAddon = self.appDelegate.transactionObserver.filtersPurchased;
    
    if( hasFilterAddon ) {
        
        self.adView.hidden = YES;
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ADS_ON];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } else {
        
        // show store
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.shopController];
        
        [self presentViewController:navigationController animated:YES completion: nil];
        
    }
    
    
    [[[GAI sharedInstance] defaultTracker]
     send:[[GAIDictionaryBuilder createEventWithCategory:@"uiAction"
                                                  action:@"buttonPress"
                                                   label:@"Close Ad"
                                                   value:nil] build]];
}


- (void)addTitleToNavigationItem:(NSString *)titleText
{
    UILabel *navTitle = [[UILabel alloc] init];
/*    navTitle.backgroundColor = [UIColor clearColor]; */
//    navTitle.textColor = [UIColor colorWithRed:233.0f/255.0f green:224.0f/255.0f blue:201.0f/255.0f alpha:1.0f];

//    navTitle.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    navTitle.textAlignment = NSTextAlignmentCenter;
    // navTitle.font = [UIFont boldSystemFontOfSize:17];
    navTitle.font = [UIFont systemFontOfSize:17];
//    navTitle.shadowColor = [UIColor grayColor];
//    navTitle.shadowOffset = CGSizeMake(0, -1.0);

    navTitle.text = titleText;
    self.navigationItem.titleView = navTitle;
    [navTitle sizeToFit];
}


- (BOOL)areFiltersSet {
    BOOL filtersAreSet = NO;
    if( self.namesTableView.syllableCount > 0 ) {
        filtersAreSet = YES;
    }
    if( self.namesTableView.icelandicLetterCount > -1 ) {
        filtersAreSet = YES;
    }
    if( [MinMaxPopularityViewController getMinComponentStoredRow] > 0 || [MinMaxPopularityViewController getMaxComponentStoredRow] > 0 ) {
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
- (void)setFilterBarButtonItem {
    if( [self areFiltersSet] ) {
        
        [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"barButtonIconSearchMinus.png"]];
    } else {
        
        [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"barButtonIconSearch.png"]];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    // TODO: Keyra aðeins ef þarf, t.d. ef kyn hefur breyst, en ekki við hverja birtingu.
    
    [self setGenderToLastCurrent];
    
    [self passGenderToNamesTable];
    [self passNamesPositionToNamesTable];
    
    if( self.categorySelection != nil || self.originSelection != nil ) {
        self.genderSelection.hidden = YES;
        self.namePosition.hidden = YES;

        if( self.originSelection != nil ) {
            [self addTitleToNavigationItem:self.originSelection];
        } else {
            [self addTitleToNavigationItem:self.categorySelection];
        }
    }
    self.title = self.navigationItemTitle;
    
    [self lookupAndUpdateFavoriteButtonImage];
    

    // ad visibility
    self.adView.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey:ADS_ON];
    
    // guide
    NSString *guideDismissedForVersion = [[NSUserDefaults standardUserDefaults] objectForKey:FIRST_RUN_GUIDE_BEEN_DISMISSED_FOR_VERSION];
    BOOL guideBeenDismissed = [guideDismissedForVersion isEqualToString:self.currentBuildVersion];
    // BOOL guideBeenDismissed = [[NSUserDefaults standardUserDefaults] boolForKey:FIRST_RUN_GUIDE_BEEN_DISMISSED];
    if( guideBeenDismissed ) {
        self.firstRunGuide.hidden = YES;
    } else {
        self.firstRunGuide.hidden = NO;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTaped:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [self.firstRunGuide addGestureRecognizer:singleTap];
        [self.firstRunGuide setUserInteractionEnabled:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setFilterBarButtonItem];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [[segue identifier] isEqualToString:@"NamesTableEmbedSegue"] ) {

        self.namesTableView = (NamesTableViewListController *)[segue destinationViewController];
        self.namesTableView.namesOrder = self.namesOrder;
        self.namesTableView.categorySelection = self.categorySelection;
        self.namesTableView.originSelection = self.originSelection;
        self.namesTableView.nameCardDelegate = self;
        
        [self setGenderToLastCurrent];
        
        [self passGenderToNamesTable];
        [self passNamesPositionToNamesTable];
    } else if( [[segue identifier] isEqualToString:@"ShowFilterChoices"] ) {
        FilterChoicesViewController *filterController = (FilterChoicesViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        
        filterController.delegate = self;
    }
}


- (IBAction)selectNamePosition:(id)sender {
    
    [self passNamesPositionToNamesTable];

    [[[GAI sharedInstance] defaultTracker]
     send:[[GAIDictionaryBuilder createEventWithCategory:@"uiAction"
                                                  action:@"buttonPress"
                                                   label:@"Select Name Position"
                                                   value:[NSNumber numberWithInt:self.namePosition.selectedSegmentIndex]] build]];
}

- (IBAction)selectGender:(id)sender {
    if( self.namesTableView ) {
        
        NSString *selectedGender = [self passGenderToNamesTable];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:selectedGender forKey:GENDER_SELECTION_STORAGE_KEY];
        [userDefaults synchronize];
        
        [self clearNameCard];
    }
    
    
    [[[GAI sharedInstance] defaultTracker]
     send:[[GAIDictionaryBuilder createEventWithCategory:@"uiAction"
                                                  action:@"buttonPress"
                                                   label:@"Select Gender"
                                                   value:[NSNumber numberWithInt:self.genderSelection.selectedSegmentIndex]] build]];
}

- (void)setGenderToLastCurrent
{
    NSString *currentGenderSelection = [[NSUserDefaults standardUserDefaults] stringForKey:GENDER_SELECTION_STORAGE_KEY];
    if( currentGenderSelection ) {
        if( [currentGenderSelection isEqualToString:GENDER_MALE] ) {
            self.genderSelection.selectedSegmentIndex = 0;
        } else if( [currentGenderSelection isEqualToString:GENDER_FEMALE] ) {
            self.genderSelection.selectedSegmentIndex = 1;
        }
    }
}


- (NSString *)passGenderToNamesTable
{
    self.namesTableView.genderSelection = [self getCurrentGender];
    return self.namesTableView.genderSelection;
}

- (void)passNamesPositionToNamesTable
{
    self.namesTableView.namesPosition = self.namePosition.selectedSegmentIndex;
}

- (NSString *)getCurrentGender
{
    NSString *selectedGender = nil;
    if( self.genderSelection ) {
        switch (self.genderSelection.selectedSegmentIndex) {
            case 0:
                selectedGender = GENDER_MALE;
                break;
            case 1:
                selectedGender = GENDER_FEMALE;
                break;
            default:
                break;
        }
    } else { // we don't have the gender selection control, let's grab the value from defaults
        NSString *gender = [[NSUserDefaults standardUserDefaults] stringForKey:GENDER_SELECTION_STORAGE_KEY];
        if( ! gender ) {
            gender = GENDER_MALE;
        }
        selectedGender = gender;
    }
    
    return selectedGender;
}



#pragma mark - update name card delegate

- (void)updateFavoritesButtonImageToActive
{
    [self.toggleFavoriteButton setImage:[UIImage imageNamed:@"heart_nametag"] forState:UIControlStateNormal];
}
- (void)updateFavoritesButtonImageToInctive
{
    [self.toggleFavoriteButton setImage:[UIImage imageNamed:@"heart_nametag_disabled"] forState:UIControlStateNormal];
}


- (void)updateNameCard:(NSString *)name
{
    NSString *surname = [[NSUserDefaults standardUserDefaults] stringForKey:SURNAME_STORAGE_KEY];

    NSMutableArray *nameParts = [[self.nameOnCard.text componentsSeparatedByString:@" "] mutableCopy];
    NSInteger surnameIndex = [nameParts indexOfObject:surname];
    if( surnameIndex != NSNotFound ) {
        [nameParts removeObjectAtIndex:surnameIndex];
    }
    if( surname != nil ) {
        surname = [NSString stringWithFormat:@" %@", surname];
    } else {
        surname = @"";
    }
    switch (self.namePosition.selectedSegmentIndex) {
        case 0:
            if( [nameParts count] > 1 ) {
                self.nameOnCard.text = [name stringByAppendingFormat:@" %@%@", [nameParts objectAtIndex:1], surname];
            } else {
                self.nameOnCard.text = [name stringByAppendingString:surname];
            }
            break;
            
        case 1:
            if( [nameParts count] > 0 ) {
                NSString *firstName = [nameParts objectAtIndex:0];
                if( [firstName isEqual:@""] ) {
                    self.nameOnCard.text = [name stringByAppendingString:surname];
                } else if( ! [firstName isEqual:name] ) {
                    self.nameOnCard.text = [firstName stringByAppendingFormat:@" %@%@", name, surname];
                }
            } else {
                self.nameOnCard.text = [name stringByAppendingString:surname];
            }
            break;
            
        default:
            break;
    }

    // let's check if the name is marked as a favorite after 1 second delay
    // so we won't be doing excessive db lookups when names change rapidly (scrolling fast)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        if( ! [self.currentNameLookedUpInFavorites isEqualToString:self.nameOnCard.text] ) {
            
            NSArray *existingFavoritesForName = [Favorite getFavoritesForName:self.nameOnCard.text inContext:self.favoritesDatabase.managedObjectContext];
            if( [existingFavoritesForName count] ) {
                [self updateFavoritesButtonImageToActive];
            } else {
                [self updateFavoritesButtonImageToInctive];
            }
        }
        self.currentNameLookedUpInFavorites = self.nameOnCard.text;
    });
}

- (void)clearNameCard
{
    self.nameOnCard.text = @"";
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateFavoriteButtonImageToState:(BOOL)active
{
    if( active ) {
        [self updateFavoritesButtonImageToActive];
    } else {
        [self updateFavoritesButtonImageToInctive];
    }
    

    [[[GAI sharedInstance] defaultTracker]
     send:[[GAIDictionaryBuilder createEventWithCategory:@"uiAction"
                                                  action:@"buttonPress"
                                                   label:@"Toggle favorite in Name List"
                                                   value:[NSNumber numberWithBool:active]] build]];
}

- (void)lookupAndUpdateFavoriteButtonImage{
    
    [self updateFavoriteButtonImageToState:[self.favoritesDatabaseUtility isInFavorites:self.nameOnCard.text]];
}


- (IBAction)toggleFavorite:(id)sender {
    
    [self updateFavoriteButtonImageToState:[self.favoritesDatabaseUtility toggleFavoriteForName:self.nameOnCard.text gender:[self getCurrentGender]]];
}

- (IBAction)clearNameCardAction:(id)sender {
    [self clearNameCard];
    [self updateFavoritesButtonImageToInctive];
    
    
    [[[GAI sharedInstance] defaultTracker]
     send:[[GAIDictionaryBuilder createEventWithCategory:@"uiAction"
                                                  action:@"buttonPress"
                                                   label:@"Clear Name Card"
                                                   value:nil] build]];
}



#pragma mark - ShopViewControllerDelegate

- (void)shopViewControllerDidCancel:(ShopViewController *)controller {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)shopViewControllerDidPurchase:(ShopViewController *)controller {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
