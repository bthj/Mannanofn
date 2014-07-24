//
//  WheelRandomController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 18/07/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMWheelControl.h"

#import "NameCardUpdateDelegate.h"

@protocol NameCardUpdateDelegate;


@interface WheelRandomController : UIViewController <SMWheelControlDelegate, SMWheelControlDataSource>

- (void)fetchResults;
- (void)loadFilters;

@property (nonatomic, strong) NSString *genderSelection;
@property (nonatomic, assign) NSInteger namesPosition;

@property (nonatomic, assign) NSInteger syllableCount; // 0 for any number of syllables
@property (nonatomic, assign) NSInteger icelandicLetterCount; // -1 for any number of Icelandic letters
@property (nonatomic, assign) NSInteger minPopularity;
@property (nonatomic, assign) NSInteger maxPopularity;
@property (nonatomic, strong) NSString *firstInitialFilter;
@property (nonatomic, strong) NSString *secondInitialFilter;
@property (nonatomic, strong) NSString *searchFilter;


@property (weak, nonatomic) id <NameCardUpdateDelegate> nameCardDelegate;


@end
