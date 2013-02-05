//
//  Favorite+Create.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/5/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import "Favorite+Create.h"

@implementation Favorite (Create)

+ (Favorite *)favoriteWithName:(NSString *)name withOrder:(NSNumber *)order inManagedObjectContext:(NSManagedObjectContext *)context
{
    Favorite *favorite = [NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:context];
    
    favorite.name = name;
    favorite.order = order;
    favorite.dateModified = [NSDate date];
    
    return favorite;
}

@end
