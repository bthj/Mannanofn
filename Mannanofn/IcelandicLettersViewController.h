//
//  IcelandicLettersViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 25/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IcelandicLettersViewControllerDelegate;



@interface IcelandicLettersViewController : UITableViewController

@property (weak, nonatomic) id <IcelandicLettersViewControllerDelegate> delegate;

@property (nonatomic, assign) NSInteger icelandicLetterCount; // -1 for any number of Icelandic letters

+ (BOOL)isIcelandicLetterCountFilterSet;

@end



@protocol IcelandicLettersViewControllerDelegate <NSObject>

- (void)icelandicLetterCountChosen:(IcelandicLettersViewController *)controller icelandicLetterCount:(NSInteger)icelandicLetterCount;

@end