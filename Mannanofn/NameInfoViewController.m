//
//  NameInfoViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 2/4/13.
//  Copyright (c) 2013 nemur.net. All rights reserved.
//

#import "NameInfoViewController.h"
#import "FavoritesDatabaseUtility.h"

@interface NameInfoViewController ()

@property (strong, nonatomic) FavoritesDatabaseUtility *favoritesDatabaseUtility;

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
        self.addDescriptionButton.hidden = YES;
        self.changeDescriptionButton.hidden = NO;
    } else {
        self.descriptionLegend.hidden = YES;
        self.addDescriptionButton.hidden = NO;
        self.changeDescriptionButton.hidden = YES;
    }
    
    self.originLabel.text = self.origin;
    if( [self.origin length] > 0 ) {
        self.originLegend.hidden = NO;
    } else {
        self.originLegend.hidden = YES;
    }
    
    self.countAsFirstNameLabel.text = [self.countAsFirstName stringValue];
    self.countAsSecondNameLabel.text = [self.countAsSecondName stringValue];
    
    [self.toggleFavoriteButton setEnabled:NO];  // to be disabled until favorites db is ready
    self.favoritesDatabaseUtility = [[FavoritesDatabaseUtility alloc] initFavoritesDatabaseForView: self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateFavoritesButtonImageToActive
{
    [self.toggleFavoriteButton setImage:[UIImage imageNamed:@"first"] forState:UIControlStateNormal];
}
- (void)updateFavoritesButtonImageToInctive
{
    [self.toggleFavoriteButton setImage:[UIImage imageNamed:@"second"] forState:UIControlStateNormal];
}
- (IBAction)toggleFavorite:(id)sender {
    
    if( [self.favoritesDatabaseUtility toggleFavoriteForName:self.name] ) {
        [self updateFavoritesButtonImageToActive];
    } else {
        [self updateFavoritesButtonImageToInctive];
    }
}

- (IBAction)mailDescription:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"@mailto:nemur@nemur.net?subject=Nefna:%20Athugasemd%20við%20merkingu%20nafnsins%20 " stringByAppendingString:self.name]]];
}

@end
