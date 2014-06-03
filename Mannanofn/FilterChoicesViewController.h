//
//  FilterChoicesTableViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 20/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FilterChoicesTableViewControllerDelegate;



@interface FilterChoicesViewController : UITableViewController

@property (weak, nonatomic) id <FilterChoicesTableViewControllerDelegate> delegate;


@property (weak, nonatomic) IBOutlet UITableViewCell *clearFiltersCell;
    

@property (weak, nonatomic) IBOutlet UITableViewCell *searchCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *syllableCountCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *extendedLetterCountCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *popularityFilterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *initialsCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *surnameCell;

@property (weak, nonatomic) IBOutlet UISwitch *advertisementSwitch;

@property (weak, nonatomic) IBOutlet UITableViewCell *aboutUsCell;


- (IBAction)done:(id)sender;

- (IBAction)switchAds:(UISwitch *)sender;

@end



@protocol FilterChoicesTableViewControllerDelegate <NSObject>

- (void)filterChoicesTableViewControllerDidCancel:(FilterChoicesViewController *)controller;
- (void)filterChoicesTableViewControllerDidFinish:(FilterChoicesViewController *)controller;

@end