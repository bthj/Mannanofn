//
//  SyllablesChoicesViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 20/01/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SyllablesChoicesViewControllerDelegate;



@interface SyllablesChoicesViewController : UITableViewController

@property (weak, nonatomic) id <SyllablesChoicesViewControllerDelegate> delegate;

@property (nonatomic, assign) NSInteger syllableCount; // 0 for any number of syllables

@end



@protocol SyllablesChoicesViewControllerDelegate <NSObject>

- (void)syllableCountChosen:(SyllablesChoicesViewController *)controller syllableCount:(NSInteger)syllableCount;

@end