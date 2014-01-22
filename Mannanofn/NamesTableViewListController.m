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
#import "NameInfoViewController.h"
#import "MBProgressHUD.h"
#import "GAI.h"
#import "GAIFields.h"


@interface NamesTableViewListController ()

@property (strong, nonatomic) NamesDatabaseSetupUtility *namesDatabaseSetup;
@property (nonatomic, strong) UIManagedDocument *namesDatabase;

@end



@implementation NamesTableViewListController

@synthesize namesDatabase = _namesDatabase;

@synthesize genderSelection = _genderSelection;
@synthesize namesOrder = _namesOrder;

@synthesize categorySelection = _categorySelection;
@synthesize originSelection = _originSelection;



- (void)setupFetchedResultsController //attaches an NSFetchRequest to this UITableViewController
{    

    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Name"];

    NSMutableArray *predicateFormats = [NSMutableArray array];
    NSMutableArray *predicateArguments = [NSMutableArray array];

    if( self.syllableCount > 0 ) {
        [predicateFormats addObject:@"countSyllables == %d"];
        [predicateArguments addObject:[NSNumber numberWithInt:self.syllableCount]];
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
                                   [NSSortDescriptor sortDescriptorWithKey:@"countAsFirstName" ascending:NO],
                                   [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
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

- (void)loadFilters
{
    self.syllableCount = [[NSUserDefaults standardUserDefaults] integerForKey:SYLLABLES_COUNT_STORAGE_KEY];
}

- (void)fetchResults
{
    if( self.namesDatabase ) {
        [self setupFetchedResultsController];
    }
}


- (void)updateNameCardFromVisibleCells
{
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
            [self.nameCardDelegate updateNameCard:oneVisibleCell.textLabel.text];
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;


}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadFilters];
    
    self.namesDatabaseSetup = [[NamesDatabaseSetupUtility alloc] initNamesDatabaseForView:self.view];
    self.namesDatabaseSetup.fetchedResultsSetupDelegate = self;
    
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:[NSString stringWithFormat:@"Names Screen, in order %@ for gender %@", self.namesOrder, self.genderSelection]];
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
    
    // index text color - from http://stackoverflow.com/a/10412958/169858
    for(UIView *view in [tableView subviews]) {
        if([view respondsToSelector:@selector(setIndexColor:)]) {
            // light yellow with transparency
            // [view performSelector:@selector(setIndexColor:) withObject:[UIColor colorWithRed:233.0f/255.0f green:224.0f/255.0f blue:201.0f/255.0f alpha:0.66f]];
            // white with transparency
            [view performSelector:@selector(setIndexColor:) withObject:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.55f]];
        }
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
    int numberOfSectionsInTableView;
    if( [self.namesOrder isEqualToString:ORDER_BY_FIRST_NAME_POPULARITY] ) {
        numberOfSectionsInTableView = floor( [self.fetchedResultsController.fetchedObjects count] / NUMER_OF_ROWS_IN_POPULARITY_SECTION );
        return numberOfSectionsInTableView;
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
            if( (section+1)  ==  [self numberOfSectionsInTableView:table] ) {
                int numberOfRowsInLastSection = [self.fetchedResultsController.fetchedObjects count] - ((section+1) * 10);
                return numberOfRowsInLastSection;
            } else {
                return 10;
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
        headerTitle = @"";
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
                headerTitle = [NSString stringWithFormat:@"%d", ((section-1) * NUMER_OF_ROWS_IN_POPULARITY_SECTION)];
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
        for( int i=0; i < [tableView numberOfSections]; i++ ) {
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
        return 0;
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
}





#pragma mark - i18n hack
// To show Icelandic characters correctly in the section index - via http://stackoverflow.com/a/3538943/169858
- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    return sectionName;
}


@end
