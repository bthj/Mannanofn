//
//  MinMaxPopularityViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 24/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MinMaxPopularityViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>


@property (weak, nonatomic) IBOutlet UIPickerView *minMaxPicker;

+ (NSInteger)getRowFromStoredValueInComponent:(NSInteger)component;

@end
