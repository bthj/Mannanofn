//
//  FavoritesDatabaseSetupUtility.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/5/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SetFavoritesDatabaseDelegate;



@interface FavoritesDatabaseUtility : NSObject

@property (weak, nonatomic) id <SetFavoritesDatabaseDelegate> setFavoritesDatabaseDelegate;

- (id)initFavoritesDatabaseForView: (UIView *)view;

- (BOOL)isInFavorites:(NSString *)name;
- (BOOL)toggleFavoriteForName:(NSString *)name gender:(NSString *)gender;

@end



@protocol SetFavoritesDatabaseDelegate <NSObject>

- (void)setFavoritesDatabase:(UIManagedDocument *)favoritesDatabase;

@end