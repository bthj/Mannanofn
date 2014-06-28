//
//  InitialsViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 25/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "InitialsViewController.h"

#import "MannanofnGlobalStringConstants.h"


@interface InitialsViewController ()

@property (nonatomic, strong) NSArray *icelandicAlphabet;

@end

@implementation InitialsViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.icelandicAlphabet = [NSArray arrayWithObjects:@"A",@"Á",@"B",@"D",@"Ð",@"E",@"É",@"F",@"G",@"H",@"I",@"Í",@"J",@"K",@"L",@"M",@"N",@"O",@"Ó",@"P",@"R",@"S",@"T",@"U",@"Ú",@"V",@"X",@"Y",@"Ý",@"Þ",@"Æ",@"Ö", nil];

    NSInteger firstInitialRow, secondInitialRow;
    NSString *storedFirstInitial = [[NSUserDefaults standardUserDefaults] stringForKey:INITIAL_FIRST_STORAGE_KEY];
    NSString *storedSecondInitial = [[NSUserDefaults standardUserDefaults] stringForKey:INITIAL_SECOND_STORAGE_KEY];
    if( storedFirstInitial ) {
        firstInitialRow = [self.icelandicAlphabet indexOfObject:storedFirstInitial] + 1;
    } else {
        firstInitialRow = 0;
    }
    if( storedSecondInitial ) {
        secondInitialRow = [self.icelandicAlphabet indexOfObject:storedSecondInitial] + 1;
    } else {
        secondInitialRow = 0;
    }
    [self.initialsPicker selectRow:firstInitialRow inComponent:0 animated:NO];
    [self.initialsPicker selectRow:secondInitialRow inComponent:1 animated:NO];
    
    
    self.screenName = @"Initials Screen";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - picker view delegation 

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.icelandicAlphabet count] + 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if( row == 0 ) {
        return @"Allt";
    } else {
        return [self.icelandicAlphabet objectAtIndex:row-1];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *storageKey;
    if( component == 0 ) {
        storageKey = INITIAL_FIRST_STORAGE_KEY;
    } else {
        storageKey = INITIAL_SECOND_STORAGE_KEY;
    }
    if( row == 0 ) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:storageKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[self.icelandicAlphabet objectAtIndex:row-1] forKey:storageKey];
    }
}



+ (BOOL)areInitialsFiltersSet
{
    NSString *storedFirstInitial = [[NSUserDefaults standardUserDefaults] stringForKey:INITIAL_FIRST_STORAGE_KEY];
    NSString *storedSecondInitial = [[NSUserDefaults standardUserDefaults] stringForKey:INITIAL_SECOND_STORAGE_KEY];
    if( nil != storedFirstInitial || nil != storedSecondInitial ) {
        return YES;
    } else {
        return NO;
    }
}



- (IBAction)done:(id)sender {
    
    [[self delegate] initialsApplied:self];
}


@end
