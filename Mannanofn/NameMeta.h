//
//  NameMeta.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 02/09/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Name.h"

@interface NameMeta : NSObject

@property (nonatomic, strong) Name *nameEntry;
@property (nonatomic, strong) NSString *favoriteString;
@property (nonatomic, assign, getter = isFavorite) BOOL favorite;

@end
