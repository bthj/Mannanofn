//
//  WheelOfFavorites.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 19/08/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "WheelOfFavorites.h"
#import "FavoritesDatabaseUtility.h"
#import "Favorite.h"


#define WHEEL_SLICE_COUNT 8


@interface WheelOfFavorites () <SetFavoritesDatabaseDelegate>

@property (strong, nonatomic) FavoritesDatabaseUtility *favoritesDatabaseUtility;
@property (strong, nonatomic) UIManagedDocument *favoritesDatabase;

@property (strong, nonatomic) NSFetchRequest *fetchFavorites;

@property (assign, nonatomic) NSUInteger favoritesCount;

@property (nonatomic, weak) SMWheelControl *wheel;

@end



@implementation WheelOfFavorites

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
    
    _fetchFavorites = [NSFetchRequest fetchRequestWithEntityName:@"Favorite"];
    
    
    // wheel
    SMWheelControl *wheel = [[SMWheelControl alloc] initWithFrame:CGRectMake(0, 52, 320, 320)];
    [wheel addTarget:self action:@selector(wheelDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    wheel.delegate = self;
    wheel.dataSource = self;
    [wheel reloadData];
    
    [self.view addSubview:wheel];
    self.wheel = wheel;
}

- (void)viewDidAppear:(BOOL)animated {
    
    if( self.favoritesDatabase ) {
        [self updateFavoriteCounts];
    } else {
        self.favoritesDatabaseUtility = [[FavoritesDatabaseUtility alloc] initFavoritesDatabaseForView:self.view];
        self.favoritesDatabaseUtility.setFavoritesDatabaseDelegate = self;
    }
}

- (void)setFavoritesDatabase:(UIManagedDocument *)favoritesDatabase
{
    if( _favoritesDatabase != favoritesDatabase ) {
        _favoritesDatabase = favoritesDatabase;
        if( favoritesDatabase ) {
            [self updateFavoriteCounts];
        }
    }
}


- (void)updateFavoriteCounts
{
    NSError *error = nil;
    
    [_fetchFavorites setFetchOffset:0];
    [_fetchFavorites setFetchLimit:0];
    _favoritesCount = [_favoritesDatabase.managedObjectContext countForFetchRequest:_fetchFavorites error:&error];
}



- (NSString *)getRandomNameFromFavorites {
    NSString *randomName;
    
    if( 0 < _favoritesCount ) {
        
        NSUInteger offset = arc4random_uniform(_favoritesCount);
        
        NSError *error = nil;
        
        [_fetchFavorites setFetchOffset:offset];
        [_fetchFavorites setFetchLimit:1];
        NSArray *favoritesResult = [_favoritesDatabase.managedObjectContext executeFetchRequest:_fetchFavorites error:&error];
        
        if( [favoritesResult count] ) {
            Favorite *favoriteManagedObject = [favoritesResult lastObject];
            randomName = favoriteManagedObject.name;
        } else {
            randomName = @"";
        }
    } else {
        randomName = @"";
    }
    
    return randomName;
}




#pragma mark - Wheel delegate

- (void)wheelDidEndDecelerating:(SMWheelControl *)wheel
{
    
}

- (void)wheel:(SMWheelControl *)wheel didRotateByAngle:(CGFloat)angle
{
    
}

#pragma mark - Wheel dataSource

- (NSUInteger)numberOfSlicesInWheel:(SMWheelControl *)wheel {

    return WHEEL_SLICE_COUNT;
}

- (UIView *)wheel:(SMWheelControl *)wheel viewForSliceAtIndex:(NSUInteger)index {
    
    UIView *sliceContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    label.backgroundColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"%li", index];
    [label setTransform:CGAffineTransformMakeRotation( - M_PI_2 )];
    
    [sliceContainer addSubview:label];
    return sliceContainer;
}

- (CGFloat)snappingAngleForWheel:(SMWheelControl *)wheel {
    
    return M_PI_2;
}

#pragma mark - Wheel Control

- (void)wheelDidChangeValue:(id)sender {
    
    self.randomNameLabel.text = [self getRandomNameFromFavorites];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
