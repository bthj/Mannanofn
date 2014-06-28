//
//  MinMaxPopularityViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 24/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"


@interface MinMaxPopularityViewController : GAITrackedViewController <UIPickerViewDataSource, UIPickerViewDelegate>


@property (weak, nonatomic) IBOutlet UIPickerView *minMaxPicker;

+ (NSInteger)getValueFromMinComponentStoredRow;
+ (NSInteger)getValueFromMaxComponentStoredRow;

+ (NSInteger)getMinComponentStoredRow;
+ (NSInteger)getMaxComponentStoredRow;

/*
+ (NSInteger)getRowFromStoredValueInComponent:(NSInteger)component;
*/
@end
