//
//  FavoritesTableViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/5/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "FavoritesDatabaseUtility.h"


@interface FavoritesTableViewController : CoreDataTableViewController <SetFavoritesDatabaseDelegate, NSFetchedResultsControllerDelegate>

@end
