//
//  NameDetailCardsViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 20/08/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Name.h"

#import "CollectionViewDataFetchDelegate.h"
#import "FavoriteToggleDelegate.h"


@protocol CollectionViewDataFetchDelegate;
@protocol FavoriteToggleDelegate;


@interface NameDetailCardsViewController : UICollectionViewController

@property (weak, nonatomic) id <CollectionViewDataFetchDelegate> collectionViewDataDelegate;
@property (weak, nonatomic) id <FavoriteToggleDelegate> favoriteToggleDelegate;

@end
