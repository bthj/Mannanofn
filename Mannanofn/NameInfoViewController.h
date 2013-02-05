//
//  NameInfoViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/4/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NameInfoViewController : UIViewController

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *origin;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *originLabel;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLegend;
@property (weak, nonatomic) IBOutlet UILabel *originLegend;

@property (weak, nonatomic) IBOutlet UIButton *mailDescriptionButton;
- (IBAction)mailDescription:(id)sender;


@end
