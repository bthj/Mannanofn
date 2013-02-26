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



@interface NamesContainerViewController ()

@property (nonatomic, strong) NamesTableViewListController *namesTableView;
@property (strong, nonatomic) FavoritesDatabaseUtility *favoritesDatabaseUtility;
@property (nonatomic, strong) UIManagedDocument *favoritesDatabase;
@property (nonatomic, strong) NSString *currentNameLookedUpInFavorites;

@end



@implementation NamesContainerViewController

@synthesize favoritesDatabase = _favoritesDatabase;

- (void)setFavoritesDatabase:(UIManagedDocument *)favoritesDatabase
{
    if( _favoritesDatabase != favoritesDatabase ) {
        _favoritesDatabase = favoritesDatabase;
    }
    if( favoritesDatabase ) {
        [self.toggleFavoriteButton setEnabled:YES];
    }
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
}

- (void)addTitleToNavigationItem:(NSString *)titleText
{
    UILabel *navTitle = [[UILabel alloc] init];
    navTitle.backgroundColor = [UIColor clearColor];
//    navTitle.textColor = [UIColor colorWithRed:233.0f/255.0f green:224.0f/255.0f blue:201.0f/255.0f alpha:1.0f];
    navTitle.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];
    navTitle.shadowColor = [UIColor grayColor];
    navTitle.shadowOffset = CGSizeMake(0, -1.0);
    navTitle.text = titleText;
    self.navigationItem.titleView = navTitle;
    [navTitle sizeToFit];
}

- (void)viewWillAppear:(BOOL)animated
{
    // TODO: Keyra aðeins ef þarf, t.d. ef kyn hefur breyst, en ekki við hverja birtingu.
    
    [self setGenderToLastCurrent];
    
    [self passGenderToNamesTable];
    
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
    }
}

- (IBAction)selectGender:(id)sender {
    if( self.namesTableView ) {
        
        NSString *selectedGender = [self passGenderToNamesTable];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:selectedGender forKey:GENDER_SELECTION_STORAGE_KEY];
        [userDefaults synchronize];
        
        [self clearNameCard];
    }
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
    NSString *selectedGender = nil;
    if( self.genderSelection ) {
        switch (self.genderSelection.selectedSegmentIndex) {
            case 0:
                self.namesTableView.genderSelection = selectedGender = GENDER_MALE;
                //            self.tableContainer.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"tableViewBackgroundBlue"]];
                //            self.nameCard.backgroundColor = [UIColor colorWithRed:58.0f/255.0f green:30.0f/255.0f blue:94.0f/255.0f alpha:1.0f];
                break;
            case 1:
                self.namesTableView.genderSelection = selectedGender = GENDER_FEMALE;
                //            self.tableContainer.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"tableViewBackgroundPink"]];
                //            self.nameCard.backgroundColor = [UIColor colorWithRed:126.0f/255.0f green:15.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
                break;
            default:
                break;
        }
    } else { // we don't have the gender selection control, let's grab the value from defaults
        NSString *gender = [[NSUserDefaults standardUserDefaults] stringForKey:GENDER_SELECTION_STORAGE_KEY];
        if( ! gender ) {
            gender = GENDER_MALE;
        }
        self.namesTableView.genderSelection = selectedGender = gender;
    }

    return selectedGender;
}



#pragma mark - update name card delegate

- (void)updateFavoritesButtonImageToActive
{
    [self.toggleFavoriteButton setImage:[UIImage imageNamed:@"first"] forState:UIControlStateNormal];
}
- (void)updateFavoritesButtonImageToInctive
{
    [self.toggleFavoriteButton setImage:[UIImage imageNamed:@"second"] forState:UIControlStateNormal];
}

- (void)updateNameCard:(NSString *)name
{
    NSArray *nameParts = [self.nameOnCard.text componentsSeparatedByString:@" "];
    switch (self.namePosition.selectedSegmentIndex) {
        case 0:
            if( [nameParts count] > 1 ) {
                self.nameOnCard.text = [name stringByAppendingFormat:@" %@", [nameParts objectAtIndex:1]];
            } else {
                self.nameOnCard.text = name;
            }
            break;
            
        case 1:
            if( [nameParts count] > 0 ) {
                self.nameOnCard.text = [[nameParts objectAtIndex:0] stringByAppendingFormat:@" %@", name];
            } else {
                self.nameOnCard.text = name;
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
}

- (void)lookupAndUpdateFavoriteButtonImage{
    
    [self updateFavoriteButtonImageToState:[self.favoritesDatabaseUtility isInFavorites:self.nameOnCard.text]];
}


- (IBAction)toggleFavorite:(id)sender {
    
    [self updateFavoriteButtonImageToState:[self.favoritesDatabaseUtility toggleFavoriteForName:self.nameOnCard.text]];
}

@end
