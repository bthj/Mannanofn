//
//  NamesControlSwappingViewController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 18/07/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "NamesControlSwappingController.h"
#import "MannanofnGlobalStringConstants.h"
#import "MinMaxPopularityViewController.h"

#import "NamesTableViewListController.h"
#import "WheelRandomController.h"

#define SegueIdentifierNamesTable @"embedNamesTableView"
#define SegueIdentifierNamesWheel @"embedNamesWheelView"

@interface NamesControlSwappingController ()

@property (strong, nonatomic) NSString *currentSegueIdentifier;
@property (strong, nonatomic) NamesTableViewListController *namesTableView;
@property (strong, nonatomic) WheelRandomController *namesWheelView;

@end



@implementation NamesControlSwappingController


@synthesize currentSegueIdentifier = _currentSegueIdentifier;
@synthesize namesTableView = _namesTableView;
@synthesize namesWheelView = _namesWheelView;

@synthesize genderSelection = _genderSelection;
@synthesize namesPosition = _namesPosition;

@synthesize namesOrder = _namesOrder;
@synthesize categorySelection = _categorySelection;
@synthesize originSelection = _originSelection;
@synthesize nameCardDelegate = _nameCardDelegate;


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
    
    if( [_currentSegueIdentifier isEqualToString:SegueIdentifierNamesTable] ) {

        self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"tableViewBackgroundBlue"]];
        
    } else if( [_currentSegueIdentifier isEqualToString:SegueIdentifierNamesWheel] ) {
        // TODO: wheel background...
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self loadFilters];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// based on https://github.com/mluton/EmbeddedSwapping
// : http://sandmoose.com/post/35714028270/storyboards-with-custom-container-view-controllers

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:SegueIdentifierNamesTable] ) {
        _namesTableView = segue.destinationViewController;

        _namesTableView.namesOrder = _namesOrder;
/*
        _namesTableView.categorySelection = _categorySelection;
        _namesTableView.originSelection = _originSelection;
 */
    }
    if( [segue.identifier isEqualToString:SegueIdentifierNamesWheel] ) {
        _namesWheelView = segue.destinationViewController;
    }
    
    if( self.childViewControllers.count > 0 ) {
        
        if( [segue.identifier isEqualToString:SegueIdentifierNamesTable] ) {
            
            [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:_namesTableView];
            
        } else if( [segue.identifier isEqualToString:SegueIdentifierNamesWheel] ) {

            [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:_namesWheelView];
        }
        
    } else {
        // If this is the very first time we're loading this we need to do
        // an initial load and not a swap.
        [self addChildViewController:segue.destinationViewController];
        UIView* destView = ((UIViewController *)segue.destinationViewController).view;
        destView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        destView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:destView];
        [segue.destinationViewController didMoveToParentViewController:self];
    }
    
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    return _currentSegueIdentifier ? YES : NO;
}

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    [self transitionFromViewController:fromViewController toViewController:toViewController duration:0 options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
    }];
}


- (void)setNamesOrder:(NSString *)namesOrder {
    
    _namesOrder = namesOrder;
    
    if( [_namesOrder isEqualToString:ORDER_RANDOMLY] ) {
        
        _currentSegueIdentifier = SegueIdentifierNamesWheel;
    } else {
        
        _currentSegueIdentifier = SegueIdentifierNamesTable;
    }
    [self performSegueWithIdentifier:_currentSegueIdentifier sender:nil];
}
/*
- (void)setCategorySelection:(NSString *)categorySelection {
    
    _categorySelection = categorySelection;
    // passed to active name-choosing control in prepareForSegue
}
- (void)setOriginSelection:(NSString *)originSelection {
    
    _originSelection = originSelection;
    // passed to active name-choosing control in prepareForSegue
}
 */
- (void)setNameCardDelegate:(id)nameCardDelegate {
    
    _nameCardDelegate = nameCardDelegate;
    // passed to active name-choosing control in prepareForSegue
    
    if( [_currentSegueIdentifier isEqualToString:SegueIdentifierNamesTable] ) {
        _namesTableView.nameCardDelegate = _nameCardDelegate;
    } else if( [_currentSegueIdentifier isEqualToString:SegueIdentifierNamesWheel] ) {
        // TODO: pass name card delegate to wheel view
    }
}
- (void)setGenderSelection:(NSString *)genderSelection {
    
    _genderSelection = genderSelection;

    if( [_currentSegueIdentifier isEqualToString:SegueIdentifierNamesTable] ) {
        _namesTableView.genderSelection = _genderSelection;
    } else if( [_currentSegueIdentifier isEqualToString:SegueIdentifierNamesWheel] ) {
        // TODO: pass gender selection to wheel view
    }
}
- (void)setNamesPosition:(NSInteger)namesPosition {
    _namesPosition = namesPosition;
    
    if( [_currentSegueIdentifier isEqualToString:SegueIdentifierNamesTable] ) {
        _namesTableView.namesPosition = _namesPosition;
    } else if( [_currentSegueIdentifier isEqualToString:SegueIdentifierNamesWheel] ) {
        // TODO: probably we don't have to do anything here...
    }
}



- (void)loadFilters {

    if( [_currentSegueIdentifier isEqualToString:SegueIdentifierNamesTable] ) {

        [_namesTableView loadFilters];
        
    } else if( [_currentSegueIdentifier isEqualToString:SegueIdentifierNamesWheel] ) {

        // TODO ...pass vars to _namesWheelView ...
    }
}

- (void)fetchResults {

    if( [_currentSegueIdentifier isEqualToString:SegueIdentifierNamesTable] ) {
        
        [_namesTableView fetchResults];
     
    } else if( [_currentSegueIdentifier isEqualToString:SegueIdentifierNamesWheel] ) {
        
        // TODO: call fetchResults on _namesWheelView
    }
}



@end
