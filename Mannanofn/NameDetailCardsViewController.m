//
//  NameDetailCardsViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 20/08/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "NameDetailCardsViewController.h"
#import "NameInfoCell.h"

#define CELL_REUSE_IDENTIFIER @"NameInfoCell"


@interface NameDetailCardsViewController () // <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

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
}

- (void)viewDidLayoutSubviews {

}

- (void)viewWillAppear:(BOOL)animated {

}

- (void)viewDidAppear:(BOOL)animated {
    
    NSIndexPath *indexPathToScrollTo = [self.delegate getSelectedIndexPath];
    
    [self.collectionView scrollToItemAtIndexPath:indexPathToScrollTo atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self findCenterVisibleCellAndAskDelegateToScrollToCorrespondingTableViewCell];
}

- (void)findCenterVisibleCellAndAskDelegateToScrollToCorrespondingTableViewCell {
    
    NSArray *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
    int middleIndex = (int)[visibleIndexPaths count] / 2;
    NSIndexPath *middleIndexPath = (NSIndexPath *)[visibleIndexPaths objectAtIndex:middleIndex];
    [self.delegate scrollToIndexPathFromCollectionView:middleIndexPath];
}



#pragma mark - CollectionView delegats

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

//    return 1;
    return [self.delegate numberOfSections];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
//    return 20;
    return [self.delegate numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    Name *nameInfo = [self.delegate dataForIndexPath:indexPath];
    
    
    NameInfoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.name.text = nameInfo.name;
    
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
