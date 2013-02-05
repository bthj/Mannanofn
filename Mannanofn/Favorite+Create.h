//
//  Favorite+Create.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/5/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import "Favorite.h"

@interface Favorite (Create)

+ (Favorite *)favoriteWithName:(NSString *)name withOrder:(NSNumber *)order inManagedObjectContext:(NSManagedObjectContext *)context;

@end
