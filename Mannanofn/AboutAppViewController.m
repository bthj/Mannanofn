//
//  AboutAppViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 10/06/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "AboutAppViewController.h"

@interface AboutAppViewController ()

@end

@implementation AboutAppViewController

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
    
    NSURL *urlToShow = [NSURL URLWithString:@"http://www.nemur.net/nefna"];
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:urlToShow]];
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    self.webView.hidden = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    self.webView.hidden = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
