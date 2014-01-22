//
//  Name.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 5/17/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Name : NSManagedObject

@property (nonatomic, retain) NSString * alphabeticalKeyForName;
@property (nonatomic, retain) NSString * category1;
@property (nonatomic, retain) NSString * category2;
@property (nonatomic, retain) NSString * category3;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * countAsFirstName;
@property (nonatomic, retain) NSNumber * countAsSecondName;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * descriptionIcelandic;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * origin;
@property (nonatomic, retain) NSNumber * countSyllables;
@property (nonatomic, retain) NSNumber * countIcelandicLetters;
@property (nonatomic, retain) NSString * descriptionEnglish;

@end
