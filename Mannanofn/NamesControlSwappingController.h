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


- (void)loadFilters;
- (void)fetchResults;


@end
