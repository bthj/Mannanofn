//
//  MannanofnAppDelegate.h
//  Mannanofn
//
//  Created by Bjorn Thor Jonsson on 4/23/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TransactionObserver.h"


@interface MannanofnAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) TransactionObserver *transactionObserver;

@end
