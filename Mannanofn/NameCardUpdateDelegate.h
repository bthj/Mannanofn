//
//  NameCardUpdateDelegate.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 24/07/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NameCardUpdateDelegate <NSObject>

- (void)updateNameCard:(NSString *)name;

@end
