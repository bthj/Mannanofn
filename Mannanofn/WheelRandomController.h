//
//  WheelRandomController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 18/07/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WheelRandomController : UIViewController
    
@property (weak, nonatomic) IBOutlet UILabel *labelCount;

- (IBAction)pickRandom:(id)sender;

@end
