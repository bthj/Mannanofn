//
//  FavoritesTableViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/5/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import "Favorite.h"


@interface FavoritesTableViewController ()

@property (strong, nonatomic) FavoritesDatabaseSetupUtility *favoritesDatabaseSetup;
@property (strong, nonatomic) UIManagedDocument *favoritesDatabase;

@end



@implementation FavoritesTableViewController

@synthesize favoritesDatabase = _favoritesDatabase;


- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Favorite"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.favoritesDatabase.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
}

- (void)setFavoritesDatabase:(UIManagedDocument *)favoritesDatabase
{
    if( _favoritesDatabase != favoritesDatabase ) {
        _favoritesDatabase = favoritesDatabase;
        if( favoritesDatabase ) {
            [self setupFetchedResultsController];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Uppáhalds";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.editButtonItem.title = @"Breyta";
    
    self.favoritesDatabaseSetup = [[FavoritesDatabaseSetupUtility alloc] init];
    self.favoritesDatabaseSetup.setFavoritesDatabaseDelegate = self;
    [self.favoritesDatabaseSetup initializeFavoritesDatabase: self.view];
}
/*
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FavoriteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Favorite *favorite = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = favorite.name;
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


#pragma mark - Table view delegate

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    // ath. localization  http://stackoverflow.com/a/9917968/169858
    if( editing ) {
        self.editButtonItem.title = @"Ljúka";
    } else {
        self.editButtonItem.title = @"Breyta";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     ; *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

@end
