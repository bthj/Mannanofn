//
//  NamesTableViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 8/21/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#import "NamesTableViewController.h"
#import "Name+Create.h"

#define NAMES_READ_FROM_SEED_AT_VERSION @"namesReadFromSeedAtVersion"
#define NUMER_OF_ROWS_IN_POPULARITY_SECTION 10

@interface NamesTableViewController ()

@end

@implementation NamesTableViewController

@synthesize namesDatabase = _namesDatabase;

@synthesize genderSelection = _genderSelection;
@synthesize namesOrder = _namesOrder;

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
            // Create entity in database for each name from JSON seed
            for( NSDictionary *oneName in names ) {
                [Name nameWithSeedData:oneName inManagedObjectContext:document.managedObjectContext];
            }
            // UIManagedDocument autosaves, but let's save as soon as possible
            [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
            
            // Write app's version number at the time of this fetch to NSUserDefaults, for reference later.
            NSString *currentBuildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            [[NSUserDefaults standardUserDefaults] setObject:currentBuildVersion forKey:NAMES_READ_FROM_SEED_AT_VERSION];
        }];
    });
    dispatch_release(seedQ);
}

- (void)setupFetchedResultsController //attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Name"];
    if( self.genderSelection ) {
        request.predicate = [NSPredicate predicateWithFormat:@"gender == %@", self.genderSelection];
//        request.predicate = [NSPredicate predicateWithFormat:@"gender == %@ AND countAsFirstName != 0 AND countAsFirstName != 1", self.genderSelection];
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
    

}

- (void)useDocument
{
    if( ![[NSFileManager defaultManager] fileExistsAtPath:[self.namesDatabase.fileURL path]] ) {
        // does not exist on disk, so create it
        [self.namesDatabase saveToURL:self.namesDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
            [self fetchNamesIntoDocument:self.namesDatabase:NO];
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
        [self useDocument];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( !self.namesDatabase ) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"MannanofnDatabase"];
        self.namesDatabase = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create this for us on disk
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
    self.genderSelection = @"X";
    self.namesOrder = ORDER_BY_FIRST_NAME_POPULARITY;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NameCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Name *name;
    if( [self.namesOrder isEqualToString:ORDER_BY_FIRST_NAME_POPULARITY] ) {
        // let's trick fetchedResultsController as we didn't pass any sectionNameKeyPath in this case
        // and we're handling numberOfSectionsInTableView and numberOfRowsInSection here locally (yes, hackish!)
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row+(indexPath.section*NUMER_OF_ROWS_IN_POPULARITY_SECTION) inSection:0];
        name = [self.fetchedResultsController objectAtIndexPath:newIndexPath];
    } else {
        name = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    cell.textLabel.text = name.name;
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", name.countAsFirstName, name.countAsSecondName];
    
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
    if( [self.namesOrder isEqualToString:ORDER_BY_FIRST_NAME_POPULARITY] ) {
        int numberOfSectionsInTableView = floor( [self.fetchedResultsController.fetchedObjects count] / NUMER_OF_ROWS_IN_POPULARITY_SECTION );
        return numberOfSectionsInTableView;
    } else {
        return [[self.fetchedResultsController sections] count];
    }

}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if( [self.namesOrder isEqualToString:ORDER_BY_FIRST_NAME_POPULARITY] ) {
        if( (section+1)  ==  [self numberOfSectionsInTableView:table] ) {
            int numberOfRowsInLastSection = [self.fetchedResultsController.fetchedObjects count] - ((section+1) * 10);
            return numberOfRowsInLastSection;
        } else {
            return 10;
        }
        
    } else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerTitle;
    if( [self.namesOrder isEqualToString:ORDER_BY_FIRST_NAME_POPULARITY] ) {
        if( 0 == section ) {
            if( [self.genderSelection isEqualToString:GENDER_FEMALE] ) {
                headerTitle = @"Stúlknanöfn í vinsældaröð";
            } else if( [self.genderSelection isEqualToString:GENDER_MALE] ) {
                headerTitle = @"Drengjanöfn í vinsældaröð";
            } else {
                headerTitle = @"Vinsælustu nöfnin";
            }
        } else {
            headerTitle = [NSString stringWithFormat:@"%d", (section * NUMER_OF_ROWS_IN_POPULARITY_SECTION)];
        }
    } else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        headerTitle = [sectionInfo name];
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





#pragma mark - i18n hack
// To show Icelandic characters correctly in the section index - via http://stackoverflow.com/a/3538943/169858
- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    return sectionName;
}


@end
