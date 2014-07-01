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
    return NSLocalizedString(alphaChar, nil);
    
//    NSLog( @"%@: \"%@\"", self.name, alphaChar );
    
//    return alphaChar;
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
    if( ! [[nameSeed objectForKey:@"countIcelandicLetters"] isEqual:[NSNull null]] ) {
        name.countIcelandicLetters = [NSNumber numberWithInteger:[[nameSeed objectForKey:@"countIcelandicLetters"] integerValue]];
    }
    if( ! [[nameSeed objectForKey:@"countSyllables"] isEqual:[NSNull null]] ) {
        name.countSyllables = [NSNumber numberWithInteger:[[nameSeed objectForKey:@"countSyllables"] integerValue]];
    }
    name.comment = [[nameSeed objectForKey:@"comment"] isEqual:[NSNull null]] ? nil : [nameSeed objectForKey:@"comment"];
    name.category1 = [[nameSeed objectForKey:@"category1"] isEqual:[NSNull null]] ? nil : [[nameSeed objectForKey:@"category1"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    name.category2 = [[nameSeed objectForKey:@"category2"] isEqual:[NSNull null]] ? nil : [[nameSeed objectForKey:@"category2"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    name.category3 = [[nameSeed objectForKey:@"category3"] isEqual:[NSNull null]] ? nil : [[nameSeed objectForKey:@"category3"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    name.dateAdded = [self getDateFromISOString:[nameSeed objectForKey:@"dateAdded"]];
    name.dateModified = [self getDateFromISOString:[nameSeed objectForKey:@"dateModified"]];
    
    // temporary debug
    if( [name.name isEqualToString:@"Analía"] ) {
        NSLog(@"Found Analía and its description is: %@", name.descriptionIcelandic);
    }
    
    return name;
}

+ (Name *)getNameForName:(NSString *)name inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Name"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSError *error = nil;
    NSArray *names = [context executeFetchRequest:request error:&error];
    Name *nameManagedObject = nil;
    if( [names count] ) {
        nameManagedObject = [names lastObject];
    }
    return nameManagedObject;
}


+ (NSDate *)getDateFromISOString: (NSString *)dateString {
    NSDate *date = nil;
    if( ! [dateString isEqual:[NSNull null]] ) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSS'Z'"];
        date = [dateFormat dateFromString:dateString];
    }
    return date;
}

@end
