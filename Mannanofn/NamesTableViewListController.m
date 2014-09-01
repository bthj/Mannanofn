//
//  NamesTableViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 8/21/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#import "NamesTableViewListController.h"
#import "Name.h"
#import "MannanofnGlobalStringConstants.h"
#import "MinMaxPopularityViewController.h"
#import "NameInfoViewController.h"
#import "MBProgressHUD.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


@interface NamesTableViewListController () <CollectionViewDataFetchDelegate>

@property (strong, nonatomic) NamesDatabaseSetupUtility *namesDatabaseSetup;
@property (nonatomic, strong) UIManagedDocument *namesDatabase;

@property (nonatomic, strong) NSIndexPath *indexPathToScrollTo;

@end



@implementation NamesTableViewListController

@synthesize namesDatabase = _namesDatabase;

@synthesize genderSelection = _genderSelection;
@synthesize namesPosition = _namesPosition;

@synthesize namesOrder = _namesOrder;

@synthesize categorySelection = _categorySelection;
@synthesize originSelection = _originSelection;



- (void)setupFetchedResultsController //attaches an NSFetchRequest to this UITableViewController
{    

    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Name"];

    NSMutableArray *predicateFormats = [NSMutableArray array];
    NSMutableArray *predicateArguments = [NSMutableArray array];
    
    NSString *popularitySortDescriptorKey;
    if( self.namesPosition == 0 ) {
        popularitySortDescriptorKey = @"countAsFirstName";
    } else {
        popularitySortDescriptorKey = @"countAsSecondName";
    }

    if( ! self.categorySelection && ! self.originSelection ) {
        
        if( self.syllableCount > 0 ) {
            [predicateFormats addObject:@"countSyllables == %d"];
            [predicateArguments addObject:[NSNumber numberWithLong:self.syllableCount]];
        }
        if( self.icelandicLetterCount > -1 ) {
            [predicateFormats addObject:@"countIcelandicLetters == %d"];
            [predicateArguments addObject:[NSNumber numberWithLong:self.icelandicLetterCount]];
        }
        
        if( self.minPopularity > 0 ) {
            [predicateFormats addObject:[popularitySortDescriptorKey stringByAppendingString:@" >= %d"]];
            [predicateArguments addObject:[NSNumber numberWithLong:self.minPopularity]];
        }
        if( self.maxPopularity < MAX_TOTAL_NUMBER_OF_NAMES ) {
            [predicateFormats addObject:[popularitySortDescriptorKey stringByAppendingString:@" <= %d"]];
            [predicateArguments addObject:[NSNumber numberWithLong:self.maxPopularity]];
        }
        
        if( self.firstInitialFilter != nil && self.namesPosition == 0 ) {
            [predicateFormats addObject:@"name beginswith %@"];
            [predicateArguments addObject:self.firstInitialFilter];
        }
        if( self.secondInitialFilter != nil && self.namesPosition == 1 ) {
            [predicateFormats addObject:@"name beginswith %@"];
            [predicateArguments addObject:self.secondInitialFilter];
        }
        
        if( self.searchFilter != nil && [self.searchFilter length] > 0 ) {
            [predicateFormats addObject:@"name contains[c] %@"];
            [predicateArguments addObject:self.searchFilter];
        }
    }

    if( self.genderSelection ) {
//            request.predicate = [NSPredicate predicateWithFormat:@"gender == %@", self.genderSelection];
        [predicateFormats addObject:@"gender == %@"];
        [predicateArguments addObject:self.genderSelection];
    }
    if( self.categorySelection ) {
        [predicateFormats addObject:@"(category1 == %@ OR category2 == %@ OR category3 == %@)"];
        [predicateArguments addObjectsFromArray:@[self.categorySelection,self.categorySelection,self.categorySelection]];
    }
    if( self.originSelection ) {
        [predicateFormats addObject:@"origin == %@"];
        [predicateArguments addObject:self.originSelection];
    }
    if( [predicateArguments count] ) {
        request.predicate = [NSPredicate predicateWithFormat:[predicateFormats componentsJoinedByString:@" AND "] argumentArray:predicateArguments];
    }
 
    if( [self.namesOrder isEqualToString:ORDER_BY_FIRST_NAME_POPULARITY] ) {

        request.sortDescriptors = [NSArray arrayWithObjects:
                                   [NSSortDescriptor sortDescriptorWithKey:popularitySortDescriptorKey ascending:NO],
//                                   [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
                                   [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES],
                                   nil];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.namesDatabase.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]];

        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.namesDatabase.managedObjectContext
                                                                              sectionNameKeyPath:@"alphabeticalKeyForName"
                                                                                       cacheName:nil];
    }
    
    [self updateNameCardFromVisibleCells];
    
//    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)setNamesDatabase:(UIManagedDocument *)namesDatabase
{
    if( _namesDatabase != namesDatabase ) {
        _namesDatabase = namesDatabase;
        if( namesDatabase ) {
            [self setupFetchedResultsController];
        }
    }
}


- (void)setGenderSelection:(NSString *)genderSelection
{
    _genderSelection = genderSelection;
    
    [self fetchResults];
}
- (void)setNamesPosition:(NSInteger)namesPosition
{
    _namesPosition = namesPosition;
    
    [self fetchResults];
}


- (void)loadFilters
{
    self.syllableCount = [[NSUserDefaults standardUserDefaults] integerForKey:SYLLABLES_COUNT_STORAGE_KEY];
    self.icelandicLetterCount = [[NSUserDefaults standardUserDefaults] integerForKey:ICELANDIC_LETTER_COUNT_STORAGE_KEY] - 1 ;

    self.minPopularity = [MinMaxPopularityViewController getValueFromMinComponentStoredRow];
    self.maxPopularity = [MinMaxPopularityViewController getValueFromMaxComponentStoredRow];
    
    self.firstInitialFilter = [[NSUserDefaults standardUserDefaults] stringForKey:INITIAL_FIRST_STORAGE_KEY];
    self.secondInitialFilter = [[NSUserDefaults standardUserDefaults] stringForKey:INITIAL_SECOND_STORAGE_KEY];
    
    self.searchFilter = [[NSUserDefaults standardUserDefaults] stringForKey:SEARCH_STRING_STORAGE_KEY];
}

- (void)fetchResults
{
    if( self.namesDatabase ) {
        [self setupFetchedResultsController];
    }
}



- (void)updateNameCardFromVisibleCells
{
    UITableViewCell *cellUnderScan = [self getMiddleVisibleCell];
    [self.nameCardDelegate updateNameCard:cellUnderScan.textLabel.text];	
}

- (UITableViewCell *)getMiddleVisibleCell {
    UITableViewCell *middleCell;
    
    int visibleCount = 0;
    int visibleCellReference;
    if( IS_WIDESCREEN ) { // iPhone 5 and such...
        visibleCellReference = 9;
    } else {
        visibleCellReference = 7;
    }
    int matchIndex = [self.tableView.visibleCells count] <= visibleCellReference ? 4 : 5;
    for( UITableViewCell *oneVisibleCell in self.tableView.visibleCells ) {
        visibleCount++;
        if( visibleCount == matchIndex ) {
            middleCell = oneVisibleCell;
        }
    }
    return middleCell;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    
    self.indexPathToScrollTo = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadFilters];
    
    self.namesDatabaseSetup = [[NamesDatabaseSetupUtility alloc] initNamesDatabaseForView:self.view];
    self.namesDatabaseSetup.fetchedResultsSetupDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:[NSString stringWithFormat:@"Names Screen, in order %@ for gender %@", self.namesOrder, self.genderSelection]];
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    // scroll to an index path converted from the center index path in the detail collection view
    if( self.indexPathToScrollTo ) {
        
        [self.tableView scrollToRowAtIndexPath:self.indexPathToScrollTo atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
        self.indexPathToScrollTo = nil;
    }
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}





#pragma mark - Table view delegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateNameCardFromVisibleCells];
}


- (BOOL)isIndexPathWithinData:(NSIndexPath *)indexPath
{
    return indexPath.section != 0 && (indexPath.section+1) != [self numberOfSectionsInTableView:self.tableView];
}

- (Name *)getNameAtIndexPath:(NSIndexPath *)indexPath
{
    Name *name;
    
    // as we're padding with an empty section on top (and at bottom) we need to adjust for the section index here
    NSIndexPath *adjustedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
    
    if( [self.namesOrder isEqualToString:ORDER_BY_FIRST_NAME_POPULARITY] ) {
        // let's trick fetchedResultsController as we didn't pass any sectionNameKeyPath in this case
        // and we're handling numberOfSectionsInTableView and numberOfRowsInSection here locally (yes, hackish!)
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:adjustedIndexPath.row+(adjustedIndexPath.section*NUMER_OF_ROWS_IN_POPULARITY_SECTION) inSection:0];
        name = [self.fetchedResultsController objectAtIndexPath:newIndexPath];
    } else {
        name = [self.fetchedResultsController objectAtIndexPath:adjustedIndexPath];
    }
    return name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NameCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if( indexPath.section == 0 || (indexPath.section+1) == [self numberOfSectionsInTableView:tableView] ) {  // first or last padding sections
        cell.textLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;


        // Configure the cell...
        Name *name = [self getNameAtIndexPath:indexPath];
        cell.textLabel.text = name.name;
        //    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", name.countAsFirstName, name.countAsSecondName];
    }



    // index bar color
    if ([tableView respondsToSelector:@selector(setSectionIndexColor:)]) {
        
        tableView.sectionIndexColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.55f];
    }

    if ([tableView respondsToSelector:@selector(setSectionIndexBackgroundColor:)]) {
        
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        // ef vill annan bakgrunnslit þegar dregið eftir indexinum:
        // tableView.sectionIndexTrackingBackgroundColor =
    }
 
    
    // white text with some transparency
    cell.textLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.87f];

    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    long numberOfSectionsInTableView;
    if( [self.namesOrder isEqualToString:ORDER_BY_FIRST_NAME_POPULARITY] ) {
        numberOfSectionsInTableView = ceil( 1.0 * [self.fetchedResultsController.fetchedObjects count] / NUMER_OF_ROWS_IN_POPULARITY_SECTION );
//        if( numberOfSectionsInTableView == 0 ) numberOfSectionsInTableView = 1;
//        return numberOfSectionsInTableView;
    } else {
        numberOfSectionsInTableView = [[self.fetchedResultsController sections] count];
    }
    // two extra sections for padding at top and bottom
    // so all content rows can be moved to the middle of the table view where a virtual scan is performed
    return numberOfSectionsInTableView + 2;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {

    if( section == 0 ) {  // first or last padding sections
        return 3;
    } else if( (section+1) == [self numberOfSectionsInTableView:table] ) {
        if( IS_WIDESCREEN ) {
            return 5;  // iPhone 5 needs more padding at bottom
        } else {
            return 3;
        }
    } else {

        if( [self.namesOrder isEqualToString:ORDER_BY_FIRST_NAME_POPULARITY] ) {
            if( (section+2)  ==  [self numberOfSectionsInTableView:table] ) {
                long numberOfRowsInLastSection;
                if( [self.fetchedResultsController.fetchedObjects count] > NUMER_OF_ROWS_IN_POPULARITY_SECTION ) {
                    numberOfRowsInLastSection = [self.fetchedResultsController.fetchedObjects count] - ((section-1) * NUMER_OF_ROWS_IN_POPULARITY_SECTION);
                } else {
                    numberOfRowsInLastSection = [self.fetchedResultsController.fetchedObjects count];
                }
                return numberOfRowsInLastSection;
            } else {
                return NUMER_OF_ROWS_IN_POPULARITY_SECTION;
            }
        } else {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:(section - 1)]; // -1 because one padding section at top
            return [sectionInfo numberOfObjects];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerTitle;
    if( section == 0 || (section+1) == [self numberOfSectionsInTableView:self.tableView] ) {  // first or last padding sections
        if( [self.fetchedResultsController.fetchedObjects count] == 0 && section == 0 ) {
            headerTitle = @"Ekkert nafn uppfyllir leitarskilyrðin";
        } else {
            headerTitle = @"";
        }
    } else {
        if( [self.namesOrder isEqualToString:ORDER_BY_FIRST_NAME_POPULARITY] ) {
            if( 1 == section ) {
                if( [self.genderSelection isEqualToString:GENDER_FEMALE] ) {
                    headerTitle = @"Stúlknanöfn í vinsældaröð";
                } else if( [self.genderSelection isEqualToString:GENDER_MALE] ) {
                    headerTitle = @"Drengjanöfn í vinsældaröð";
                } else {
                    headerTitle = @"Vinsælustu nöfnin";
                }
            } else {
                headerTitle = [NSString stringWithFormat:@"%ld", ((section-1) * NUMER_OF_ROWS_IN_POPULARITY_SECTION)];
            }
        } else if( [self.namesOrder isEqualToString:ORDER_BY_NAME] ) {
            if( 1 == section ) {
                if( [self.genderSelection isEqualToString:GENDER_FEMALE] ) {
                    headerTitle = @"Stúlknanöfn í stafrófsröð";
                } else if( [self.genderSelection isEqualToString:GENDER_MALE] ) {
                    headerTitle = @"Drengjanöfn í stafrófsröð";
                } else {
                    headerTitle = @"Nöfn í stafrófsröð";
                }
            } else {
                
                id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section-1];
                headerTitle = [sectionInfo name];
            }
        } else {
            
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
            headerTitle = [sectionInfo name];
        }
    }
    return headerTitle;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if( [self.namesOrder isEqualToString:ORDER_BY_FIRST_NAME_POPULARITY] ) {
        NSMutableArray *sectionIndexTitles = [[NSMutableArray alloc] init];
        for( int i=0; i < [tableView numberOfSections]-2; i++ ) {
            if( i == 0 ) {
                [sectionIndexTitles addObject:@"1"];
            } else if( i < 10 || 0 == (i % 10) ) {
                [sectionIndexTitles addObject:[NSString stringWithFormat:@"%d", (i * 10)]];
            }
        }
        return sectionIndexTitles;
    } else {
        return [self.fetchedResultsController sectionIndexTitles];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSInteger sectionIndex;
    if( [self.namesOrder isEqualToString:ORDER_BY_FIRST_NAME_POPULARITY] ) {
        if( index <= 10 ) {
            sectionIndex = index;
        } else {
            sectionIndex = (index-9) * 10;
        }
    } else {
        sectionIndex = [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
    }
    return sectionIndex;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if( section == 0 || (section+1) == [self numberOfSectionsInTableView:self.tableView] ) {  // first or last padding sections
        if( [self.fetchedResultsController.fetchedObjects count] == 0 && section == 0 ) {
            return 22;
        } else {
            return 0;
        }
    } else {
        return 22;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 0, 320, 22);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkGrayColor];  //[UIColor colorWithRed:255.0f/255.0f green:100.0f/255.0f blue:40.0f/255.0f alpha:1.0f];
//    label.shadowColor = [UIColor grayColor];
//    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    [sectionView setBackgroundColor:[UIColor colorWithRed:233.0f/255.0f green:224.0f/255.0f blue:201.0f/255.0f alpha:0.8f]];
    
    [sectionView addSubview:label];
    
    return sectionView;
}



#pragma mark - CollectionViewDataFetchDelegate

- (NSInteger)numberOfSections {
    
    return 1;
//    return [self numberOfSectionsInTableView:self.tableView];
//    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    
    return (NSInteger)[self.fetchedResultsController.fetchedObjects count];
//    return [self tableView:self.tableView numberOfRowsInSection:section];
//    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSArray *)dataForIndexPath:(NSIndexPath *)indexPath {

    if( [self.namesOrder isEqualToString:ORDER_BY_FIRST_NAME_POPULARITY] ) {

        // both the popularity and collection view index paths have a single section
        
        return [NSArray arrayWithObjects:[self.fetchedResultsController objectAtIndexPath:indexPath], nil];
        
    } else {
        
        // the alphabetical order index path has one section for each of the letters of the alphabet
        // and each section has a varying number of rows, so we have to translate the flat
        // single row index path from the collection view into a index path with the correct
        // section and row index for the alphabetical table:
        
        long rowIndexInCollectionView = indexPath.row;
        
        long rowSumInTableView = 0;
        long previousSectionRowSum  = 0;
        
        int sectionIndex = 0;
        long rowIndex = 0;
        for( ; sectionIndex < [[self.fetchedResultsController sections] count]; sectionIndex++ ) {
            
            rowSumInTableView += [[[self.fetchedResultsController sections] objectAtIndex:sectionIndex] numberOfObjects];
            
            if( rowSumInTableView >= rowIndexInCollectionView ) {
                
                rowIndex = rowIndexInCollectionView - previousSectionRowSum;
                
                break;
            } else {
                previousSectionRowSum = rowSumInTableView;
            }
        }
        
        NSIndexPath *alphabeticalIndexpath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
        
        return [NSArray arrayWithObjects:[self.fetchedResultsController objectAtIndexPath:alphabeticalIndexpath], nil];
    }
    

}

- (NSIndexPath *)getSelectedIndexPath {
    
    // UITableViewCell *middleCell = [self getMiddleVisibleCell];
    // NSIndexPath *middleIndexPath = [self.tableView indexPathForCell:middleCell];
    NSIndexPath *middleIndexPath = [self.tableView indexPathForSelectedRow];
    long rowIndex = 0;
    
    if( [self.namesOrder isEqualToString:ORDER_BY_FIRST_NAME_POPULARITY] ) {
        
        // (middleIndexPath.section-1) for the top padding section 
        rowIndex = (middleIndexPath.section-1) * NUMER_OF_ROWS_IN_POPULARITY_SECTION + middleIndexPath.row;
        
    } else {
        
        for( int sectionIndex = 0; sectionIndex < middleIndexPath.section - 1; sectionIndex++ ) {
            
            rowIndex += [[[self.fetchedResultsController sections] objectAtIndex:sectionIndex] numberOfObjects];
        }
        rowIndex += middleIndexPath.row;
        
    }
    
    return [NSIndexPath indexPathForRow:rowIndex inSection:0];
}

- (void)scrollToIndexPathFromCollectionView:(NSIndexPath *)indexPath {
    
    int sectionIndex = 0;
    long rowIndex = 0;

    if( [self.namesOrder isEqualToString:ORDER_BY_FIRST_NAME_POPULARITY] ) {
        
        //                                                         +1 for the padding section
        sectionIndex = floor( indexPath.row / NUMER_OF_ROWS_IN_POPULARITY_SECTION ) + 1;
        rowIndex = indexPath.row - (sectionIndex - 1) * NUMER_OF_ROWS_IN_POPULARITY_SECTION;
        
    } else {

        long rowSumInTableView = 0;
        long previousSectionRowSum  = 0;
    
        long sectionCount = [[self.fetchedResultsController sections] count];
        for( ; sectionIndex < sectionCount; sectionIndex++ ) {
            
            rowSumInTableView += [[[self.fetchedResultsController sections] objectAtIndex:sectionIndex] numberOfObjects];
            
            if( rowSumInTableView >= indexPath.row ) {
                
                rowIndex = indexPath.row - previousSectionRowSum - 1;
                
                break;
            } else {
                previousSectionRowSum = rowSumInTableView;
            }
        }
        ++sectionIndex;  // for the top padding section

    }
 
    self.indexPathToScrollTo = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
}



- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender  // requires iOS 6
{
    BOOL shouldPerformSegue = [self isIndexPathWithinData:[self.tableView indexPathForSelectedRow]];
    if( ! shouldPerformSegue ) {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
    return shouldPerformSegue;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NameInfoViewController *nameInfo = (NameInfoViewController *)[segue destinationViewController];
 
    Name *name = [self getNameAtIndexPath:[self.tableView indexPathForSelectedRow]];
    nameInfo.name = name.name;
    nameInfo.description = name.descriptionIcelandic;
    nameInfo.origin = name.origin;
    nameInfo.countAsFirstName = name.countAsFirstName;
    nameInfo.countAsSecondName = name.countAsSecondName;
    
    nameInfo.collectionViewDataDelegate = self;
}





#pragma mark - i18n hack
// To show Icelandic characters correctly in the section index - via http://stackoverflow.com/a/3538943/169858
- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    return sectionName;
}


@end
