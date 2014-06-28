//
//  MinMaxPopularityViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 24/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "MinMaxPopularityViewController.h"

#import "MannanofnGlobalStringConstants.h"


#define NAMES_COUNT_STEP 500


@interface MinMaxPopularityViewController ()

@end

@implementation MinMaxPopularityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.minMaxPicker selectRow:[[NSUserDefaults standardUserDefaults] integerForKey:MIN_POPULARITY_STORAGE_KEY] inComponent:0 animated:NO];
    [self.minMaxPicker selectRow:[[NSUserDefaults standardUserDefaults] integerForKey:MAX_POPULARITY_STORAGE_KEY] inComponent:1 animated:NO];
    
    
    self.screenName = @"Min Max Popularity Screen";
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return (MAX_TOTAL_NUMBER_OF_NAMES / NAMES_COUNT_STEP);
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%ld", (long)[MinMaxPopularityViewController getValueFromRow:row inComponent:component]];
}



- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSInteger distanceFromMaxRowInMaxCol = [pickerView numberOfRowsInComponent:1] - ([pickerView selectedRowInComponent:1]+1);
    if( component == 0 ) {

        if( distanceFromMaxRowInMaxCol < row) {
            NSInteger rowInComponent1ToAdjustTo = [pickerView selectedRowInComponent:1]-(row-distanceFromMaxRowInMaxCol);
            [pickerView selectRow:rowInComponent1ToAdjustTo inComponent:1 animated:YES];

            [[NSUserDefaults standardUserDefaults] setInteger:rowInComponent1ToAdjustTo forKey:MAX_POPULARITY_STORAGE_KEY];
        }
        [[NSUserDefaults standardUserDefaults] setInteger:row forKey:MIN_POPULARITY_STORAGE_KEY];
        
    } else {
        
        if( distanceFromMaxRowInMaxCol < [pickerView selectedRowInComponent:0] ) {
            NSInteger rowInComponent0ToAdjustTo = [pickerView selectedRowInComponent:0]-([pickerView selectedRowInComponent:0]-distanceFromMaxRowInMaxCol);
            [pickerView selectRow:rowInComponent0ToAdjustTo inComponent:0 animated:YES];

            [[NSUserDefaults standardUserDefaults] setInteger:rowInComponent0ToAdjustTo forKey:MIN_POPULARITY_STORAGE_KEY];
        }
        [[NSUserDefaults standardUserDefaults] setInteger:row forKey:MAX_POPULARITY_STORAGE_KEY];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (NSInteger)getValueFromRow:(NSInteger)row inComponent:(NSInteger)component
{
    if( component == 0 ) {
        return row * NAMES_COUNT_STEP;
    } else {
        return MAX_TOTAL_NUMBER_OF_NAMES - row * NAMES_COUNT_STEP;
    }
}

+ (NSInteger)getValueFromMinComponentStoredRow
{
    return [MinMaxPopularityViewController getValueFromRow:[MinMaxPopularityViewController getMinComponentStoredRow] inComponent:0];
}
+ (NSInteger)getValueFromMaxComponentStoredRow
{
    return [MinMaxPopularityViewController getValueFromRow:[MinMaxPopularityViewController getMaxComponentStoredRow] inComponent:1];
}

+ (NSInteger)getMinComponentStoredRow;
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:MIN_POPULARITY_STORAGE_KEY];
}
+ (NSInteger)getMaxComponentStoredRow;
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:MAX_POPULARITY_STORAGE_KEY];
}



- (IBAction)done:(id)sender {
    
    [[self delegate] minMaxApplied:self];
}


@end
