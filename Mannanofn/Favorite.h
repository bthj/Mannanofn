//
//  Favorite.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 3/15/13.
//  Copyright (c) 2013 Síminn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Favorite : NSManagedObject

@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * gender;

@end
