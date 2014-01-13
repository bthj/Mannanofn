//
//  FavoritesTableViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/5/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import "Favorite.h"
#import "Name+Create.h"
#import "NameInfoViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


@interface FavoritesTableViewController ()

@property (strong, nonatomic) FavoritesDatabaseUtility *favoritesDatabaseUtility;
@property (strong, nonatomic) UIManagedDocument *favoritesDatabase;

@property (strong, nonatomic) NamesDatabaseSetupUtility *namesDatabaseSetup;
@property (nonatomic, strong) UIManagedDocument *namesDatabase;

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

- (void)setNamesDatabase:(UIManagedDocument *)namesDatabase
{
    if( _namesDatabase != namesDatabase ) {
        _namesDatabase = namesDatabase;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Uppáhalds";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.editButtonItem.title = @"Breyta";
    
//    self.tableView.backgroundColor = [UIColor colorWithRed:112.0f/255.0f green:158.0f/255.0f blue:11.0f/255.0f alpha:1.0f];
//    self.tableView.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:174.0f/255.0f blue:243.0f/255.0f alpha:1.0f];
    // dökkblái
//    self.tableView.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:105.0f/255.0f blue:133.0f/255.0f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithRed:233.0f/255.0f green:224.0f/255.0f blue:201.0f/255.0f alpha:1.0f];
    
    self.namesDatabaseSetup = [[NamesDatabaseSetupUtility alloc] initNamesDatabaseForView:self.view];
    self.namesDatabaseSetup.fetchedResultsSetupDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    if( self.favoritesDatabase ) {
        [self setupFetchedResultsController];
    } else {
        self.favoritesDatabaseUtility = [[FavoritesDatabaseUtility alloc] initFavoritesDatabaseForView:self.view];
        self.favoritesDatabaseUtility.setFavoritesDatabaseDelegate = self;
    }
    
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:@"Favorites Screen"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FavoriteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Favorite *favorite = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = favorite.name;
    
//    cell.textLabel.textColor = [UIColor colorWithRed:233.0f/255.0f green:224.0f/255.0f blue:201.0f/255.0f alpha:1.0f];
    cell.textLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.87f];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.favoritesDatabase.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *favorites = [[self.fetchedResultsController fetchedObjects] mutableCopy];
    
    Favorite *movingFavorite = [self.fetchedResultsController objectAtIndexPath:fromIndexPath];
    
    [favorites removeObject:movingFavorite];
    [favorites insertObject:movingFavorite atIndex:toIndexPath.row];
    
    int i=0;
    for( Favorite *oneFavorite in favorites ) {
        [oneFavorite setValue:[NSNumber numberWithInt:i++] forKey:@"order"];
    }
}



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
    [self.tableView setEditing:editing animated:animated];
    
    // ath. localization  http://stackoverflow.com/a/9917968/169858
    if( editing ) {
        self.editButtonItem.title = @"Ljúka";
    } else {
        self.editButtonItem.title = @"Breyta";
        
        [self.favoritesDatabase saveToURL:self.favoritesDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
    }

    
    [[[GAI sharedInstance] defaultTracker]
     send:[[GAIDictionaryBuilder createEventWithCategory:@"uiAction"
                                                  action:@"buttonPress"
                                                   label:@"Edit Favorites"
                                                   value:[NSNumber numberWithBool:editing]] build]];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Fjarlægja";
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NameInfoViewController *nameInfo = (NameInfoViewController *)[segue destinationViewController];
    
    Favorite *favorite = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    NSArray *nameParts = [favorite.name componentsSeparatedByString:@" "];
    if( [nameParts count] == 2 ) {
        
        Name *name1 = [Name getNameForName:[nameParts objectAtIndex:0] inContext:self.namesDatabase.managedObjectContext];
        Name *name2 = [Name getNameForName:[nameParts objectAtIndex:1] inContext:self.namesDatabase.managedObjectContext];
        
        nameInfo.name = favorite.name;
        nameInfo.gender = favorite.gender;
        
        nameInfo.descriptionLegend = [name1.name stringByAppendingString:@":"];
        nameInfo.description = name1.descriptionIcelandic;
        
        nameInfo.originLegend = [name2.name stringByAppendingString:@":"];
        nameInfo.origin = name2.descriptionIcelandic;
        
        nameInfo.countAsFirstName = name1.countAsFirstName;
        nameInfo.countAsSecondName = name2.countAsSecondName;
        
    } else if( [nameParts count] == 1 ) {
        
        Name *name = [Name getNameForName:favorite.name inContext:self.namesDatabase.managedObjectContext];
        nameInfo.name = name.name;
        nameInfo.gender = name.gender;
        nameInfo.description = name.descriptionIcelandic;
        nameInfo.origin = name.origin;
        nameInfo.countAsFirstName = name.countAsFirstName;
        nameInfo.countAsSecondName = name.countAsSecondName;
    }
}

@end
