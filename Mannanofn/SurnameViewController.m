//
//  SurnameViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 30/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "SurnameViewController.h"

#import "MannanofnGlobalStringConstants.h"


@interface SurnameViewController ()

@end

@implementation SurnameViewController

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
    self.surnameInput.text = [[NSUserDefaults standardUserDefaults] stringForKey:SURNAME_STORAGE_KEY];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if( [self.surnameInput.text length] == 0 ) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SURNAME_STORAGE_KEY];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:self.surnameInput.text forKey:SURNAME_STORAGE_KEY];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}



#pragma mark - UITextFieldDelegate protocol method

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if( textField == self.surnameInput ) {
        [textField resignFirstResponder];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    return YES;
}

@end
