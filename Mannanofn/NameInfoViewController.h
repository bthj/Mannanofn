//
//  NameInfoViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/4/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoritesDatabaseUtility.h"

@interface NameInfoViewController : UIViewController <SetFavoritesDatabaseDelegate>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *descriptionLegend;
@property (nonatomic, strong) NSString *origin;
@property (nonatomic, strong) NSString *originLegend;
@property (nonatomic, strong) NSNumber *countAsFirstName;
@property (nonatomic, strong) NSNumber *countAsSecondName;


@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *originLabel;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLegendLabel;
@property (weak, nonatomic) IBOutlet UILabel *originLegendLabel;

@property (weak, nonatomic) IBOutlet UILabel *countAsFirstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countAsSecondNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *addDescriptionButton;

@property (weak, nonatomic) IBOutlet UIButton *toggleFavoriteButton;
- (IBAction)toggleFavorite:(id)sender;


- (IBAction)mailDescription:(id)sender;

- (IBAction)openAdUrl:(id)sender;

@end
