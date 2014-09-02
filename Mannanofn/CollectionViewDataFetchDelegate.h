//
//  CollectionViewDataFetchDelegate.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 22/08/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Name.h"


@protocol CollectionViewDataFetchDelegate <NSObject>

- (NSInteger)numberOfSections;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (NSArray *)dataForIndexPath:(NSIndexPath *)indexPath; // array of Name instances

- (NSIndexPath *)getSelectedIndexPath;

- (void)scrollToIndexPathFromCollectionView:(NSIndexPath *)indexPath;

- (void)refetchData;

@end
