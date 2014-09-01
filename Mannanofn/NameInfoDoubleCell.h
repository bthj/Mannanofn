//
//  NameInfoDoubleCell.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 01/09/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteToggleDelegate.h"


@protocol FavoriteToggleDelegate;



@interface NameInfoDoubleCell : UICollectionViewCell

@property (weak, nonatomic) id <FavoriteToggleDelegate> favoriteToggleDelegate;


@property (weak, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) NSString *gender;


@property (weak, nonatomic) IBOutlet UILabel *name1;
@property (weak, nonatomic) IBOutlet UILabel *name1meaning;
@property (weak, nonatomic) IBOutlet UILabel *name1origin;



@property (weak, nonatomic) IBOutlet UILabel *name2;
@property (weak, nonatomic) IBOutlet UILabel *name2meaning;
@property (weak, nonatomic) IBOutlet UILabel *name2origin;


@property (weak, nonatomic) IBOutlet UIButton *btnToggleFavorite;
- (IBAction)toggleFavorite:(id)sender;



@end
