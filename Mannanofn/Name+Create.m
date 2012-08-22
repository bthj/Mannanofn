//
//  Names+Create.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 8/21/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#import "Name+Create.h"

@implementation Name (Create)

- (NSString *)alphabeticalKeyForName
{
    [self willAccessValueForKey:@"alphabeticalKeyForName"];
    NSString *alphaChar = [[self name] substringToIndex:1];
    [self didAccessValueForKey:@"alphabeticalKeyForName"];
    return alphaChar;
}

+ (Name *)nameWithSeedData:(NSDictionary *)nameSeed
     inManagedObjectContext:(NSManagedObjectContext *)context
{
    Name *name = [NSEntityDescription insertNewObjectForEntityForName:@"Name" inManagedObjectContext:context];
    name.name = [nameSeed objectForKey:@"name"];
    name.gender = [nameSeed objectForKey:@"gender"];
    name.descriptionIcelandic = [nameSeed objectForKey:@"descriptionIcelandic"];
    name.origin = [nameSeed objectForKey:@"origin"];
    name.countAsFirstName = [NSNumber numberWithInteger:[[nameSeed objectForKey:@"countAsFirstName"] integerValue]];
    name.countAsSecondName = [NSNumber numberWithInteger:[[nameSeed objectForKey:@"countAsSecondName"] integerValue]];
    name.comment = [nameSeed objectForKey:@"comment"];
    name.category = [nameSeed objectForKey:@"category"];
    
    return name;
}

@end
