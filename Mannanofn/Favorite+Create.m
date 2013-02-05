//
//  Favorite+Create.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/5/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import "Favorite+Create.h"

@implementation Favorite (Create)



+ (Favorite *)favoriteWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    Favorite *favorite = [NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:context];
    
    favorite.name = name;
    favorite.order = [self getNextAvailableOrderIndex:context];
    favorite.dateModified = [NSDate date];
    
    return favorite;
}



+ (NSNumber *)getNextAvailableOrderIndex:(NSManagedObjectContext *)context
{
    // let's get the highest ordering index
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Favorite"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *favorites = [context executeFetchRequest:request error:&error];
    Favorite *lastFavorite = [favorites lastObject];
    NSInteger order = 1;
    if( lastFavorite ) {
        order = [[lastFavorite valueForKey:@"order"] integerValue] + 1;
    }
    return [NSNumber numberWithInteger:order];
}

@end
