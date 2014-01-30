//
//  SearchConstraintsViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 25/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "SearchViewController.h"

#import "MannanofnGlobalStringConstants.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.searchInputField.text = [[NSUserDefaults standardUserDefaults] stringForKey:SEARCH_STRING_STORAGE_KEY];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if( [self.searchInputField.text length] == 0 ) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SEARCH_STRING_STORAGE_KEY];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:self.searchInputField.text forKey:SEARCH_STRING_STORAGE_KEY];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (BOOL)isSearchFilterSet
{
    NSString *searchFilter = [[NSUserDefaults standardUserDefaults] stringForKey:SEARCH_STRING_STORAGE_KEY];
    if( searchFilter != nil && [searchFilter length] > 0 ) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - UITextFieldDelegate protocol method

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if( textField == self.searchInputField ) {
        [textField resignFirstResponder];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    return YES;
}

@end
