//
//  SearchConstraintsViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 25/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"


@protocol SearchViewControllerDelegate;


@interface SearchViewController : GAITrackedViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchInputField;

+ (BOOL)isSearchFilterSet;


@property (weak, nonatomic) id <SearchViewControllerDelegate> delegate;


@end



@protocol SearchViewControllerDelegate <NSObject>

- (void)searchCriteriaApplied:(SearchViewController *)controller;

@end