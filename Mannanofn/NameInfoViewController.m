//
//  NameInfoViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/4/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import "NameInfoViewController.h"

@interface NameInfoViewController ()

@end

@implementation NameInfoViewController

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
    
    self.nameLabel.text = self.name;
    
    self.descriptionLabel.text = self.description;
    if( [self.description length] > 0 ) {
        self.descriptionLegend.hidden = NO;
        [self.mailDescriptionButton setTitle:@"Veistu betur?" forState:UIControlStateNormal];
    } else {
        self.descriptionLegend.hidden = YES;
        [self.mailDescriptionButton setTitle: @"Veistu merkinguna?" forState:UIControlStateNormal];
    }
    
    self.originLabel.text = self.origin;
    if( [self.origin length] > 0 ) {
        self.originLegend.hidden = NO;
    } else {
        self.originLegend.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)mailDescription:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"@mailto:nemur@nemur.net?subject=Nefna:%20Athugasemd%20við%20merkingu%20nafnsins%20 " stringByAppendingString:self.name]]];
}

@end
