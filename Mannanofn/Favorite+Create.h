//
//  Favorite+Create.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/5/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import "Favorite.h"

@interface Favorite (Create)

+ (Favorite *)addFavoriteWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)removeFavoriteWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSArray *)getFavoritesForName:(NSString *)name inContext:(NSManagedObjectContext *)context;

@end
