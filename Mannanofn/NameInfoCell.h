//
//  NameInfoCell.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 21/08/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteToggleDelegate.h"


@protocol FavoriteToggleDelegate;



@interface NameInfoCell : UICollectionViewCell

@property (weak, nonatomic) id <FavoriteToggleDelegate> favoriteToggleDelegate;


@property (weak, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) NSString *gender;


@property (weak, nonatomic) IBOutlet UIButton *btnToggleFavorite;
- (IBAction)toggleFavorite:(id)sender;


@property (weak, nonatomic) IBOutlet UILabel *meaning;
@property (weak, nonatomic) IBOutlet UILabel *origin;

@property (weak, nonatomic) IBOutlet UILabel *countAsFirst;
@property (weak, nonatomic) IBOutlet UILabel *countAsSecond;

@property (nonatomic, assign, getter = isFavorite) BOOL favorite;

//@property (strong, nonatomic) UIView *contentView;

@end
