//
//  WheelOfFavorites.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 19/08/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMWheelControl.h"


@interface WheelOfFavorites : UIViewController <SMWheelControlDelegate, SMWheelControlDataSource>


@property (weak, nonatomic) IBOutlet UILabel *randomNameLabel;

@end
