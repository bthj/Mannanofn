//
//  InitialsViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 25/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"


@protocol InitialsViewControllerDelegate;



@interface InitialsViewController : GAITrackedViewController <UIPickerViewDataSource, UIPickerViewDelegate>


@property (weak, nonatomic) IBOutlet UIPickerView *initialsPicker;


+ (BOOL)areInitialsFiltersSet;


- (IBAction)done:(id)sender;


@property (weak, nonatomic) id <InitialsViewControllerDelegate> delegate;


@end



@protocol InitialsViewControllerDelegate <NSObject>

- (void)initialsApplied:(InitialsViewController *)controller;

@end