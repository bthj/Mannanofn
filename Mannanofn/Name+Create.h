//
//  Names+Create.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 8/21/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#import "Name.h"

@interface Name (Create)

+ (Name *)nameWithSeedData:(NSDictionary *)nameSeed
     inManagedObjectContext:(NSManagedObjectContext *)context;

@end
