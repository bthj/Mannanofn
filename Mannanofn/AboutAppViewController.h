//
//  AboutAppViewController.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 10/06/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"


@interface AboutAppViewController : GAITrackedViewController <UIWebViewDelegate>


@property (weak, nonatomic) IBOutlet UIWebView *webView;


@end
