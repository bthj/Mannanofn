//
//  NamesTableViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 8/21/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#import "NamesTableViewController.h"
#import "Name+Create.h"
#import "MBProgressHUD.h"
#import "MannanofnGlobalStringConstants.h"

#define NAMES_READ_FROM_SEED_AT_VERSION @"namesReadFromSeedAtVersion"
#define NUMER_OF_ROWS_IN_POPULARITY_SECTION 10

@interface NamesTableViewController ()

@end

@implementation NamesTableViewController

@synthesize namesDatabase = _namesDatabase;

@synthesize genderSelection = _genderSelection;
@synthesize namesOrder = _namesOrder;
@synthesize showCategories = _showCategories;
@synthesize categorySelection = _categorySelection;

- (NSArray *)getNamesFromJSONSeed
{
    NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"names" ofType:@"json"]];
    NSError *parseError = nil;
    NSArray *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&parseError] : nil;
    
    if( parseError == nil ) {
        return results;
    }
    return nil;
}

- (NSFetchRequest *)getRequestForAllNames
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Name"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    // no predicate because we want all names
    return request;
}

- (void)fetchNamesIntoDocument:(UIManagedDocument *)document:(BOOL)reset
{    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Hleð inn nöfnum...";
    dispatch_queue_t seedQ = dispatch_queue_create("Names database seeding", NULL);
    dispatch_async(seedQ, ^{
        NSArray *names = [self getNamesFromJSONSeed];
        [document.managedObjectContext performBlock:^{ // perform in the NSMOC's safe thread (main thread)
            if( reset ) {
                // Delete all entries from Name table
                NSFetchRequest *request = [self getRequestForAllNames];
                NSError *error = nil;
                NSArray *namesToDelete = [document.managedObjectContext executeFetchRequest:request error:&error];
                for( Name *oneNameToDelete in namesToDelete ) {
                    [document.managedObjectContext deleteObject:oneNameToDelete];
                }
                [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
            }
            
            // !!! TODO: DELETE THIS!
            // sleep a while to show the activity indicator
            //   [NSThread sleepForTimeInterval:arc4random() % 5];
            // !!! TODO: DELETE THIS - end
            
            // Create entity in database for each name from JSON seed
            for( NSDictionary *oneName in names ) {
                [Name nameWithSeedData:oneName inManagedObjectContext:document.managedObjectContext];
            }
            
//            [document updateChangeCount:UIDocumentChangeDone];
            
            // UIManagedDocument autosaves, but let's save as soon as possible
            [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {

//                [self setupFetchedResultsController];
            }];
            
            // Write app's version number at the time of this fetch to NSUserDefaults, for reference later.
            NSString *currentBuildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            [[NSUserDefaults standardUserDefaults] setObject:currentBuildVersion forKey:NAMES_READ_FROM_SEED_AT_VERSION];
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    });
//    dispatch_release(seedQ);
}



- (void)setupFetchedResultsController //attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Name"];
    if( self.showCategories ) {
        request = [NSFetchRequest fetchRequestWithEntityName:@"Name"];
    } else {
        request = [NSFetchRequest fetchRequestWithEntityName:@"Name"];
    }
    NSMutableArray *predicateFormats = [NSMutableArray array];
    NSMutableArray *predicateArguments = [NSMutableArray array];

    if( self.genderSelection ) {
            request.predicate = [NSPredicate predicateWithFormat:@"gender == %@", self.genderSelection];
        [predicateFormats addObject:@"gender == %@"];
        [predicateArguments addObject:self.genderSelection];
    }
    if( self.categorySelection ) {
        [predicateFormats addObject:@"category == %@"];
        [predicateArguments addObject:self.categorySelection];
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
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.namesDatabase.managedObjectContext
                                                                              sectionNameKeyPath:@"alphabeticalKeyForName"
                                                                                       cacheName:nil];
    }
    
    [self updateNameCardFromVisibleCells];
}

- (void)useDocument
{
    if( ![[NSFileManager defaultManager] fileExistsAtPath:[self.namesDatabase.fileURL path]] ) {
        // does not exist on disk, so create it
        [self.namesDatabase saveToURL:self.namesDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
            [self fetchNamesIntoDocument:self.namesDatabase:NO];
//            [self setupFetchedResultsController];

        }];
    } else if( self.namesDatabase.documentState == UIDocumentStateClosed ) {
        // exists on disk, but we need to open it
        [self.namesDatabase openWithCompletionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
        }];
    } else if( self.namesDatabase.documentState == UIDocumentStateNormal ) {
        // already open and ready to use
        [self setupFetchedResultsController];
    }

    NSString *namesReadFromSeedAtVersion = [[NSUserDefaults standardUserDefaults] objectForKey:NAMES_READ_FROM_SEED_AT_VERSION];
    NSString *currentBuildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if( namesReadFromSeedAtVersion && ![currentBuildVersion isEqualToString:namesReadFromSeedAtVersion] ) {
        // current app version doesn't match the one in NSUserDefault's NAMES_READ_FROM_SEED_AT_VERSION
        // let's delete everything from the Name table and read in again from the seed
        [self fetchNamesIntoDocument:self.namesDatabase:YES];
    }
}

- (void)setNamesDatabase:(UIManagedDocument *)namesDatabase
{
    if( _namesDatabase != namesDatabase ) {
        _namesDatabase = namesDatabase;
        if( namesDatabase ) {
            [self useDocument];
        }
    }
}

- (void)setGenderSelection:(NSString *)genderSelection
{
    _genderSelection = genderSelection;
    
    if( self.namesDatabase ) {
        [self setupFetchedResultsController];
    }
}

- (void)initializeNamesDatabase
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"MannanofnDatabase"];
    
    self.namesDatabase = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create this for us on disk
}


- (void)updateNameCardFromVisibleCells
{
    int visibleCount = 0;
//    NSLog(@"count visibleCells:  %u", [self.tableView.visibleCells count]);
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


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( ! self.namesDatabase ) {
        
        [self initializeNamesDatabase];
    }
}



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
    
    
    // TODO: temporary gender selection
//    self.categorySelection = @"Frumlegast";
//    self.namesOrder = ORDER_BY_NAME;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    

    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
}

- (void)viewDidUnload
{
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

        // as we're padding with an empty section on top (and at bottom) we need to adjust for the section index here
        NSIndexPath *adjustedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
        
        // Configure the cell...
        Name *name;
        if( [self.namesOrder isEqualToString:ORDER_BY_FIRST_NAME_POPULARITY] ) {
            // let's trick fetchedResultsController as we didn't pass any sectionNameKeyPath in this case
            // and we're handling numberOfSectionsInTableView and numberOfRowsInSection here locally (yes, hackish!)
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:adjustedIndexPath.row+(adjustedIndexPath.section*NUMER_OF_ROWS_IN_POPULARITY_SECTION) inSection:0];
            name = [self.fetchedResultsController objectAtIndexPath:newIndexPath];
        } else {
            name = [self.fetchedResultsController objectAtIndexPath:adjustedIndexPath];
        }
        cell.textLabel.text = name.name;
        //    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", name.countAsFirstName, name.countAsSecondName];
    }
    
    // from http://stackoverflow.com/a/10412958/169858
    for(UIView *view in [tableView subviews]) {
        if([view respondsToSelector:@selector(setIndexColor:)]) {
            [view performSelector:@selector(setIndexColor:) withObject:[UIColor colorWithRed:233.0f/255.0f green:224.0f/255.0f blue:201.0f/255.0f alpha:0.66f]];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
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

    if( section == 0 || (section+1) == [self numberOfSectionsInTableView:table] ) {  // first or last padding sections
        return 3;
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
    label.textColor = [UIColor grayColor];  //[UIColor colorWithRed:255.0f/255.0f green:100.0f/255.0f blue:40.0f/255.0f alpha:1.0f];
//    label.shadowColor = [UIColor grayColor];
//    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    [sectionView setBackgroundColor:[UIColor colorWithRed:233.0f/255.0f green:224.0f/255.0f blue:201.0f/255.0f alpha:1.0f]];
    
    [sectionView addSubview:label];
    
    return sectionView;
}





#pragma mark - i18n hack
// To show Icelandic characters correctly in the section index - via http://stackoverflow.com/a/3538943/169858
- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    return sectionName;
}


@end
