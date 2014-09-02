//
//  NameDetailCardsViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 20/08/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "NameDetailCardsViewController.h"
#import "NameInfoCell.h"
#import "NameInfoDoubleCell.h"
#import "MannanofnGlobalStringConstants.h"
#import "NameMeta.h"

#define CELL_REUSE_IDENTIFIER @"NameInfoCell"
#define CELL_REUSE_IDENTIFIER_DOUBLE_NAME @"NameInfoCellDoubleName"


@interface NameDetailCardsViewController () <FavoriteToggleDelegate>

@property (strong, nonatomic) NSString *surname;

@end

@implementation NameDetailCardsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
//    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER];
    

//    [self.collectionView registerClass:[NameInfoCell class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER];
/*
    self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
*/
}

- (void)viewDidLayoutSubviews {

//    NSIndexPath *indexPathToScrollTo = [self.delegate getSelectedIndexPath];
//    [self.collectionView scrollToItemAtIndexPath:indexPathToScrollTo atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {

    self.surname = [[NSUserDefaults standardUserDefaults] stringForKey:SURNAME_STORAGE_KEY];
}

- (void)viewDidAppear:(BOOL)animated {

    NSIndexPath *indexPathToScrollTo = [self.collectionViewDataDelegate getSelectedIndexPath];
    UICollectionViewLayoutAttributes *layoutAtIndexPath = [self.collectionView layoutAttributesForItemAtIndexPath:indexPathToScrollTo];
    
    [self.collectionView setContentOffset:CGPointMake(layoutAtIndexPath.frame.origin.x-120, 0) animated:YES];
    
    // the status of the very first cards in the collection isn't correctly reflected initally
    // so we'll reload here after appearing:
    [self.collectionView reloadData];
    
    
    
//    [self.collectionView scrollToItemAtIndexPath:indexPathToScrollTo atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

//    [self.collectionView setNeedsLayout];
//    [self.collectionView layoutIfNeeded];
    
//    [self.collectionView setContentOffset:<#(CGPoint)#>
}

/*
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
    NSLog(@"scrollToItemAtIndexPath offset: %@", NSStringFromCGPoint(self.collectionView.contentOffset));
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x+120, self.collectionView.contentOffset.y)];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
    
    [self findCenterVisibleCellAndAskDelegateToScrollToCorrespondingTableViewCell];
}

- (void)findCenterVisibleCellAndAskDelegateToScrollToCorrespondingTableViewCell {
    
    NSArray *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
    int middleIndex = (int)[visibleIndexPaths count] / 2;
    NSIndexPath *middleIndexPath = (NSIndexPath *)[visibleIndexPaths objectAtIndex:middleIndex];
    [self.collectionViewDataDelegate scrollToIndexPathFromCollectionView:middleIndexPath];
}



#pragma mark - CollectionView delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

//    return 1;
    return [self.collectionViewDataDelegate numberOfSections];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
//    return 20;
    return [self.collectionViewDataDelegate numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *nameInfos = [self.collectionViewDataDelegate dataForIndexPath:indexPath];
    
    // TODO: sennilega er betra að hafa alltaf sér sellu fyrir nöfn úr favorites, óháð hvort sé tví- eða ein-
    // upp á virkni fav takkans, stöðu hans og uppfærslu collection views þegar tekið úr favorites þar.
    
    if( [nameInfos count] == 1 ) {
        
        NameMeta *nameInfo = [nameInfos objectAtIndex:0];
     
        NameInfoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
        cell.favoriteToggleDelegate = self;
        
        if( nameInfo.isFavorite ) {
            
            cell.name.text = nameInfo.favoriteString;
            
        } else {

            if( [self.surname length] == 0 ) {
                cell.name.text = nameInfo.nameEntry.name;
            } else {
                cell.name.text = [NSString stringWithFormat:@"%@ %@", nameInfo.nameEntry.name, self.surname];
            }
        }

        cell.gender = nameInfo.nameEntry.gender;
        cell.meaning.text = nameInfo.nameEntry.descriptionIcelandic;
        cell.origin.text = nameInfo.nameEntry.origin;
        cell.countAsFirst.text = [nameInfo.nameEntry.countAsFirstName stringValue];
        cell.countAsSecond.text = [nameInfo.nameEntry.countAsSecondName stringValue];
        
        cell.favorite = nameInfo.isFavorite;
        
        UIImage *favoriteButtonImage = [self.favoriteToggleDelegate getFavoriteButtonImageForName:nameInfo.favoriteString gender:nameInfo.nameEntry.gender];
        
        [cell.btnToggleFavorite setImage:favoriteButtonImage forState:UIControlStateNormal];
        
        cell.backgroundColor = [UIColor whiteColor];
        
        cell.layer.borderWidth = 1.0f;
        cell.layer.borderColor = [[UIColor blackColor] CGColor];
        
        return cell;
        
    } else if( [nameInfos count] == 2 ) {

        NameMeta *name1Info = [nameInfos objectAtIndex:0];
        NameMeta *name2Info = [nameInfos objectAtIndex:1];
        
        NameInfoDoubleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER_DOUBLE_NAME forIndexPath:indexPath];
        cell.favoriteToggleDelegate = self;
        
        if( name1Info.isFavorite ) {
            
            cell.name.text = name1Info.favoriteString;
            
        } else {
        
            if( [self.surname length] == 0 ) {
                cell.name.text = [NSString stringWithFormat:@"%@ %@", name1Info.nameEntry.name, name2Info.nameEntry.name];
            } else {
                cell.name.text = [NSString stringWithFormat:@"%@ %@ %@", name1Info.nameEntry.name, name2Info.nameEntry.name, self.surname];
            }
        }
        
        cell.gender = name1Info.nameEntry.gender;

        cell.name1.text = name1Info.nameEntry.name;
        cell.name1meaning.text = name1Info.nameEntry.descriptionIcelandic;
        cell.name1origin.text = name1Info.nameEntry.origin;

        cell.name2.text = name2Info.nameEntry.name;
        cell.name2meaning.text = name2Info.nameEntry.descriptionIcelandic;
        cell.name2origin.text = name2Info.nameEntry.origin;
        
        cell.favorite = name1Info.isFavorite;
        
        UIImage *favoriteButtonImage = [self.favoriteToggleDelegate getFavoriteButtonImageForName:name1Info.favoriteString gender:name1Info.nameEntry.gender];
        [cell.btnToggleFavorite setImage:favoriteButtonImage forState:UIControlStateNormal];
        
        cell.backgroundColor = [UIColor whiteColor];
        
        cell.layer.borderWidth = 1.0f;
        cell.layer.borderColor = [[UIColor blackColor] CGColor];
        
        return cell;
        
    } else {
        return nil;
    }

}

/*
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(198.0f, 296.0f);
}
*/

/*
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, -100, 0, -100);
}
 */



#pragma mark - FavoriteToggleDelegate

- (UIImage *)toggleFavoriteForName:(NSString *)name gender:(NSString *)gender cell:(UICollectionViewCell *)cell isFavorite:(BOOL)isFavorite {
    
    UIImage *favoriteButtonImage = [self.favoriteToggleDelegate toggleFavoriteForName:name gender:gender cell:cell isFavorite:isFavorite];
  
    
    if( isFavorite ) {
  
        // TODO: do something like:
        // [self.favoritesDatabase.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        //  ...as in FavoritesTableViewController, just via a delegate
/*
        [self.collectionViewDataDelegate refetchData];
        
        [self.collectionView performBatchUpdates:^{
            
            NSIndexPath *indexPathForDeletedRow = [self.collectionView indexPathForCell:cell];
            
//            [self.collectionView reloadData];
            
            [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObjects:indexPathForDeletedRow, nil]];
            
        } completion:^(BOOL finished) {
           

            
        }];
//        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
*/
        
    } else {
        // TODO: do     UIImage *favoriteButtonImage = [self.favoriteToggleDelegate toggleFavoriteForName:name gender:gender cell:cell isFavorite:isFavorite];
        // ...here
    }
    
//    [self.collectionView reloadData];
//    self.collectionView delete
    
    return favoriteButtonImage;
}

- (UIImage *)getFavoriteButtonImageForName:(NSString *)name gender:(NSString *)gender {

    return [self.favoriteToggleDelegate getFavoriteButtonImageForName:name gender:gender];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
