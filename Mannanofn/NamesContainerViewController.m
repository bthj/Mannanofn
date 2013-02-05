//
//  NamesContainerViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 10/23/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#import "NamesContainerViewController.h"

#import "MannanofnGlobalStringConstants.h"

@interface NamesContainerViewController ()

@property (nonatomic, strong) NamesTableViewListController *namesTable;
@property (nonatomic, strong) UIManagedDocument *favoritesDatabase;

@end



@implementation NamesContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self clearNameCard];
    
    //self.tableContainer.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableViewBackground"]];
    
    self.tableContainer.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"tableViewBackgroundBlue"]];
}

- (void)addTitleToNavigationItem:(NSString *)titleText
{
    UILabel *navTitle = [[UILabel alloc] init];
    navTitle.backgroundColor = [UIColor clearColor];
    navTitle.textColor = [UIColor colorWithRed:233.0f/255.0f green:224.0f/255.0f blue:201.0f/255.0f alpha:1.0f];
    navTitle.textAlignment = NSTextAlignmentCenter;
    navTitle.font = [UIFont boldSystemFontOfSize:20];
//    navTitle.shadowColor = [UIColor grayColor];
//    navTitle.shadowOffset = CGSizeMake(0, -1.0);
    navTitle.text = titleText;
    self.navigationItem.titleView = navTitle;
    [navTitle sizeToFit];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setGenderToLastCurrent];
    
    [self passGenderToNamesTable];
    
    if( self.categorySelection != nil ) {
        self.genderSelection.hidden = YES;
        self.namePosition.hidden = YES;

        [self addTitleToNavigationItem:self.categorySelection];
    }
    self.title = self.navigationItemTitle;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [[segue identifier] isEqualToString:@"NamesTableEmbedSegue"] ) {
        
        
        
        self.namesTable = (NamesTableViewListController *)[segue destinationViewController];
        self.namesTable.namesOrder = self.namesOrder;
        self.namesTable.categorySelection = self.categorySelection;
        self.namesTable.nameCardDelegate = self;
        
        [self setGenderToLastCurrent];
        
        [self passGenderToNamesTable];
    }
}

- (IBAction)selectGender:(id)sender {
    if( self.namesTable ) {
        
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
                self.namesTable.genderSelection = selectedGender = GENDER_MALE;
                //            self.tableContainer.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"tableViewBackgroundBlue"]];
                //            self.nameCard.backgroundColor = [UIColor colorWithRed:58.0f/255.0f green:30.0f/255.0f blue:94.0f/255.0f alpha:1.0f];
                break;
            case 1:
                self.namesTable.genderSelection = selectedGender = GENDER_FEMALE;
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
        self.namesTable.genderSelection = selectedGender = gender;
    }

    return selectedGender;
}



#pragma mark - update name card delegate

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



- (IBAction)addToFavorites:(id)sender {
}
@end
