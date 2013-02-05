//
//  Name.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/5/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Name : NSManagedObject

@property (nonatomic, retain) NSString * alphabeticalKeyForName;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * countAsFirstName;
@property (nonatomic, retain) NSNumber * countAsSecondName;
@property (nonatomic, retain) NSString * descriptionIcelandic;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * origin;

@end
