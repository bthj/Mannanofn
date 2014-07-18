//
//  NamesControlSwappingViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 18/07/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NamesControlSwappingController : UIViewController

@property (nonatomic, strong) NSString *genderSelection;
@property (nonatomic, assign) NSInteger namesPosition;

@property (nonatomic, strong) NSString *namesOrder;
@property (nonatomic, strong) NSString *categorySelection;
@property (nonatomic, strong) NSString *originSelection;
@property (nonatomic, strong) id nameCardDelegate;

/*
@property (nonatomic, assign) NSInteger syllableCount; // 0 for any number of syllables
@property (nonatomic, assign) NSInteger icelandicLetterCount; // -1 for any number of Icelandic letters
@property (nonatomic, assign) NSInteger minPopularity;
@property (nonatomic, assign) NSInteger maxPopularity;
@property (nonatomic, strong) NSString *firstInitialFilter;
@property (nonatomic, strong) NSString *secondInitialFilter;
@property (nonatomic, strong) NSString *searchFilter;
*/

- (void)loadFilters;
- (void)fetchResults;


@end