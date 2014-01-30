//
//  SearchConstraintsViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 25/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchInputField;

+ (BOOL)isSearchFilterSet;

@end
