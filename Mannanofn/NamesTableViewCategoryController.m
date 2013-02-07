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
    request.propertiesToFetch = [NSArray arrayWithObject:[[entity propertiesByName] objectForKey:@"category"]];
    request.returnsDistinctResults = YES;
    NSString *gender = [[NSUserDefaults standardUserDefaults] stringForKey:GENDER_SELECTION_STORAGE_KEY];
    if( ! gender ) {
        gender = GENDER_MALE;
    }
    request.predicate = [NSPredicate predicateWithFormat:@"gender = %@", gender];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];

    
    self.categories = [[self.namesDatabase.managedObjectContext executeFetchRequest:request error:nil] mutableCopy];
    
    // let's remove empty category
    for( int i=0; i < [self.categories count]; i++ ) {
        if( [[[self.categories objectAtIndex:i] valueForKey:@"category"] length] == 0 ) {
            [self.categories removeObjectAtIndex:i];
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



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[self.categories objectAtIndex:indexPath.row] valueForKey:@"category"];
    cell.textLabel.textColor = [UIColor colorWithRed:233.0f/255.0f green:224.0f/255.0f blue:201.0f/255.0f alpha:1.0f];
    
    return cell;
}



#pragma mark - Table view delegate

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.namesContainer = (NamesContainerViewController *)[segue destinationViewController];
    self.namesContainer.namesOrder = ORDER_BY_NAME;
    NSString *category = [[self.categories objectAtIndex:[self.tableView indexPathForSelectedRow].row] valueForKey:@"category"];;
    self.namesContainer.categorySelection = category;
    self.namesContainer.navigationItemTitle = @"Flokkar";
}

@end
