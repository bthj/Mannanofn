//
//  Favorite+Create.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/5/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import "Favorite.h"

@interface Favorite (Create)

+ (Favorite *)addFavoriteWithName:(NSString *)name gender:(NSString *)gender inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)removeFavoriteWithName:(NSString *)name gender:(NSString *)gender inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSArray *)getFavoritesForName:(NSString *)name gender:(NSString *)gender inContext:(NSManagedObjectContext *)context;

@end
