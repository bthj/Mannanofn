//
//  NamesContainerViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 10/23/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NamesContainerViewController : UIViewController

@property (assign, nonatomic) BOOL showCategories;
@property (nonatomic, strong) NSString *namesOrder;


@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSelection;


@end
