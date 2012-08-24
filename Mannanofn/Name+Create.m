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
    NSString *alphaChar = [[self name] substringToIndex:1 ];
    [self didAccessValueForKey:@"alphabeticalKeyForName"];
//    return NSLocalizedString(alphaChar, nil);
    return alphaChar;
}

+ (Name *)nameWithSeedData:(NSDictionary *)nameSeed
     inManagedObjectContext:(NSManagedObjectContext *)context
{
    Name *name = [NSEntityDescription insertNewObjectForEntityForName:@"Name" inManagedObjectContext:context];
    // ok let's go ugly
    name.name = [[nameSeed objectForKey:@"name"] isEqual:[NSNull null]] ? nil : [nameSeed objectForKey:@"name"];
    name.gender = [[nameSeed objectForKey:@"gender"] isEqual:[NSNull null]] ? nil : [nameSeed objectForKey:@"gender"];
    name.descriptionIcelandic = [[nameSeed objectForKey:@"descriptionIcelandic"] isEqual:[NSNull null]] ? nil : [nameSeed objectForKey:@"descriptionIcelandic"];
    name.origin = [[nameSeed objectForKey:@"origin"] isEqual:[NSNull null]] ? nil : [nameSeed objectForKey:@"origin"];
    name.countAsFirstName = [NSNumber numberWithInteger:[[nameSeed objectForKey:@"countAsFirstName"] integerValue]];
    name.countAsSecondName = [NSNumber numberWithInteger:[[nameSeed objectForKey:@"countAsSecondName"] integerValue]];
    name.comment = [[nameSeed objectForKey:@"comment"] isEqual:[NSNull null]] ? nil : [nameSeed objectForKey:@"comment"];
    name.category = [[nameSeed objectForKey:@"category"] isEqual:[NSNull null]] ? nil : [nameSeed objectForKey:@"category"];
    
    return name;
}


/*
- (void)setName:(NSString *)name
{
    self.name = [name isEqual:[NSNull null]] ? nil : name;
}
- (void)setGender:(NSString *)gender
{
    self.gender = [gender isEqual:[NSNull null]] ? nil : gender;
}
- (void)setDescriptionIcelandic:(NSString *)descriptionIcelandic
{
    self.descriptionIcelandic = [descriptionIcelandic isEqual:[NSNull null]] ? nil : descriptionIcelandic;
}
- (void)setOrigin:(NSString *)origin
{
    self.origin = [origin isEqual:[NSNull null]] ? nil : origin;
}
- (void)setCountAsFirstName:(NSNumber *)countAsFirstName
{
    self.countAsFirstName = [countAsFirstName isEqual:[NSNull null]] ? nil : countAsFirstName;
}
- (void)setCountAsSecondName:(NSNumber *)countAsSecondName
{
    self.countAsSecondName = [countAsSecondName isEqual:[NSNull null]] ? nil : countAsSecondName;
}
- (void)setComment:(NSString *)comment
{
    self.comment = [comment isEqual:[NSNull null]] ? nil : comment;
}
- (void)setCategory:(NSString *)category
{
    self.category = [category isEqual:[NSNull null]] ? nil : category;
}
 */

@end
