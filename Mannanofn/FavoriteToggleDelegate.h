//
//  FavoriteToggleDelegate.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 31/08/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FavoriteToggleDelegate <NSObject>

- (UIImage *)toggleFavoriteForName:(NSString *)name gender:(NSString *)gender cell:(UICollectionViewCell *)cell isFavorite:(BOOL)isFavorite;

- (UIImage *)getFavoriteButtonImageForName:(NSString *)name gender:(NSString *)gender;

@end
