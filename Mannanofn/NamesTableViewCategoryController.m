//
//  NamesTableViewCategoryControllerViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 1/30/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import "NamesTableViewCategoryController.h"
#import "NamesContainerViewController.h"
#import "MannanofnGlobalStringConstants.h"
#import "NamesDatabaseSetupUtility.h"

@interface NamesTableViewCategoryController ()

@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSMutableArray *origins;
@property (nonatomic, strong) NamesContainerViewController *namesContainer;
@property (nonatomic, strong) NamesDatabaseSetupUtility *namesDatabaseSetup;

@end



@implementation NamesTableViewCategoryController

@synthesize namesDatabase = _namesDatabase;

- (void)setNamesDatabase:(UIManagedDocument *)namesDatabase
{
    if( _namesDatabase != namesDatabase ) {
        _namesDatabase = namesDatabase;
        if( namesDatabase ) {
            [self setupFetchedResultsController];
        }
    }
}

- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Name"];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Name" inManagedObjectContext:self.namesDatabase.managedObjectContext];
    // Required! Unless you set the resultType to NSDictionaryResultType, distinct can't work.
    // All objects in the backing store are implicitly distinct, but two dictionaries can be duplicates.
    // Since you only want distinct names, only ask for the 'name' property.
    request.resultType = NSDictionaryResultType;
    request.returnsDistinctResults = YES;
    NSString *gender = [[NSUserDefaults standardUserDefaults] stringForKey:GENDER_SELECTION_STORAGE_KEY];
    if( ! gender ) {
        gender = GENDER_MALE;
    }
    request.predicate = [NSPredicate predicateWithFormat:@"gender = %@", gender];
    
    if( self.categoryTypeSelector.selectedSegmentIndex == 0 ) {

        request.propertiesToFetch = [NSArray arrayWithObject:[[entity propertiesByName] objectForKey:@"category"]];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        
        
        self.categories = [[self.namesDatabase.managedObjectContext executeFetchRequest:request error:nil] mutableCopy];
        
        // let's remove empty category
        for( int i=0; i < [self.categories count]; i++ ) {
            if( [[[self.categories objectAtIndex:i] valueForKey:@"category"] length] == 0 ) {
                [self.categories removeObjectAtIndex:i];
            }
        }
        
    } else if( self.categoryTypeSelector.selectedSegmentIndex == 1 ) {

        request.propertiesToFetch = [NSArray arrayWithObject:[[entity propertiesByName] objectForKey:@"origin"]];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"origin" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        
        self.origins = [[self.namesDatabase.managedObjectContext executeFetchRequest:request error:nil] mutableCopy];
        
        // let's remove empty origin
        for( int i=0; i < [self.origins count]; i++ ) {
            if( [[[self.origins objectAtIndex:i] valueForKey:@"origin"] length] == 0 ) {
                [self.origins removeObjectAtIndex:i];
            }
        }
        
    }

    [self.tableView reloadData];
    
/*
 NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MyEntity"];
 NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyEntity" inManagedObjectContext:self.managedObjectContext];
 
 // Required! Unless you set the resultType to NSDictionaryResultType, distinct can't work.
 // All objects in the backing store are implicitly distinct, but two dictionaries can be duplicates.
 // Since you only want distinct names, only ask for the 'name' property.
 fetchRequest.resultType = NSDictionaryResultType;
 fetchRequest.propertiesToFetch = [NSArray arrayWithObject:[[entity propertiesByName] objectForKey:@"name"]];
 fetchRequest.returnsDistinctResults = YES;
 
 // Now it should yield an NSArray of distinct values in dictionaries.
 NSArray *dictionaries = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
 NSLog (@"names: %@",dictionaries);
*/
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
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:105.0f/255.0f blue:133.0f/255.0f alpha:1.0f];
    
    self.navigationItem.title = @"Flokkar";
}

- (void)viewDidAppear:(BOOL)animated
{
    if( self.namesDatabase ) {
        [self setupFetchedResultsController];
    } else {
        self.namesDatabaseSetup = [[NamesDatabaseSetupUtility alloc] initNamesDatabaseForView:self.view];
        self.namesDatabaseSetup.fetchedResultsSetupDelegate = self;
    }
}

- (IBAction)changeCategoryType:(id)sender {
    
    [self setupFetchedResultsController];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if( self.categoryTypeSelector.selectedSegmentIndex == 0 ) {
        return [self.categories count];
    } else if( self.categoryTypeSelector.selectedSegmentIndex == 1 ) {
        return [self.origins count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if( self.categoryTypeSelector.selectedSegmentIndex == 0 ) {
        
        cell.textLabel.text = [[self.categories objectAtIndex:indexPath.row] valueForKey:@"category"];
        
    } else if( self.categoryTypeSelector.selectedSegmentIndex == 1 ) {
        
        cell.textLabel.text = [[self.origins objectAtIndex:indexPath.row] valueForKey:@"origin"];
    }
    // ljósgulur
//    cell.textLabel.textColor = [UIColor colorWithRed:233.0f/255.0f green:224.0f/255.0f blue:201.0f/255.0f alpha:1.0f];
    // white text with some transparency
    cell.textLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.85f];
    
    return cell;
}



#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.namesContainer = (NamesContainerViewController *)[segue destinationViewController];
    self.namesContainer.namesOrder = ORDER_BY_NAME;
    self.namesContainer.navigationItemTitle = @"Flokkar";
    
    if( self.categoryTypeSelector.selectedSegmentIndex == 0 ) {
        
        NSString *category = [[self.categories objectAtIndex:[self.tableView indexPathForSelectedRow].row] valueForKey:@"category"];;
        self.namesContainer.categorySelection = category;
        
    } else if( self.categoryTypeSelector.selectedSegmentIndex == 1 ) {
        
        NSString *origin = [[self.origins objectAtIndex:[self.tableView indexPathForSelectedRow].row] valueForKey:@"origin"];;
        self.namesContainer.originSelection = origin;
    }
}


@end
