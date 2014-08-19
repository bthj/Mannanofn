//
//  WheelRandomController.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 18/07/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "WheelRandomController.h"
#import "NamesDatabaseSetupUtility.h"
#import "Name.h"
#import "MannanofnGlobalStringConstants.h"

#import "MinMaxPopularityViewController.h"


@interface WheelRandomController () <SetNamesDatabaseDelegate>


@property (nonatomic, strong) NamesDatabaseSetupUtility *namesDatabaseSetup;
@property (nonatomic, strong) UIManagedDocument *namesDatabase;

@property (nonatomic, strong) NSFetchRequest *nameRequestCounts;
@property (nonatomic, strong) NSFetchRequest *nameRequestSingleNames;
@property (nonatomic, strong) NSPredicate *nameFilterPredicate;

@property (nonatomic, strong) NSMutableDictionary *alphabetCounts;
@property (nonatomic, strong) NSPredicate *namesBeginningWithLetterPredicate;


@property (nonatomic, weak) SMWheelControl *wheel;


@end



@implementation WheelRandomController

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
    
    _namesBeginningWithLetterPredicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH $letter"];
    
    // DB initialization
    self.namesDatabaseSetup = [[NamesDatabaseSetupUtility alloc] initNamesDatabaseForView:self.view];
    self.namesDatabaseSetup.fetchedResultsSetupDelegate = self;
    
    
    // wheel
    SMWheelControl *wheel = [[SMWheelControl alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [wheel addTarget:self action:@selector(wheelDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    wheel.delegate = self;
    wheel.dataSource = self;
    [wheel reloadData];
    
    [self.view addSubview:wheel];
    self.wheel = wheel;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self loadFilters];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setGenderSelection:(NSString *)genderSelection {
    
    _genderSelection = genderSelection;
    
    // TODO: Delay the call to fetch results until the view has appeared...
    // ...the call may be done multiple times (also for setNamesPosition ?)
    // -> would be better to set a flag for fetchResults to be called and then
    // look at that flag in viewDidAppear
    // ...and maybe spin the wheel automatically in viewWillAppear
    //  aaaand, something similar may need to be done in NamesTableViewListController
    
    [self fetchResults];
}

- (void)setNamesPosition:(NSInteger)namesPosition {
    
    _namesPosition = namesPosition;
    
    [self fetchResults];
}

- (void)fetchResults {
    
    if( self.namesDatabase ) {
        
        [self setupFilterPredicate];
        [self doEntityCounts];
    }
}

- (void)loadFilters {
    
    self.syllableCount = [[NSUserDefaults standardUserDefaults] integerForKey:SYLLABLES_COUNT_STORAGE_KEY];
    self.icelandicLetterCount = [[NSUserDefaults standardUserDefaults] integerForKey:ICELANDIC_LETTER_COUNT_STORAGE_KEY] - 1 ;
    
    self.minPopularity = [MinMaxPopularityViewController getValueFromMinComponentStoredRow];
    self.maxPopularity = [MinMaxPopularityViewController getValueFromMaxComponentStoredRow];
    
    self.firstInitialFilter = [[NSUserDefaults standardUserDefaults] stringForKey:INITIAL_FIRST_STORAGE_KEY];
    self.secondInitialFilter = [[NSUserDefaults standardUserDefaults] stringForKey:INITIAL_SECOND_STORAGE_KEY];
    
    self.searchFilter = [[NSUserDefaults standardUserDefaults] stringForKey:SEARCH_STRING_STORAGE_KEY];
}





#pragma mark - Wheel delegate

- (void)wheelDidEndDecelerating:(SMWheelControl *)wheel
{
    
}

- (void)wheel:(SMWheelControl *)wheel didRotateByAngle:(CGFloat)angle
{
    
}

#pragma mark - Wheel dataSource

- (NSUInteger)numberOfSlicesInWheel:(SMWheelControl *)wheel
{
    return [[[self class] firstLettersInNamesIcelandic] count];
}

- (UIView *)wheel:(SMWheelControl *)wheel viewForSliceAtIndex:(NSUInteger)index
{
/*
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    label.backgroundColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@" %@", [[[self class] firstLettersInNamesIcelandic] objectAtIndex:index] ];
    [label setTransform:CGAffineTransformMakeRotation(- M_PI / 2)];
    return label;
*/
    UIView *sliceContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    label.backgroundColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@" %@", [[[self class] firstLettersInNamesIcelandic] objectAtIndex:index] ];
    [label setTransform:CGAffineTransformMakeRotation( - M_PI_2 )];
    
    [sliceContainer addSubview:label];
    return sliceContainer;
}

- (CGFloat)snappingAngleForWheel:(SMWheelControl *)wheel {
    
    return M_PI_2;
}

#pragma mark - Wheel Control

- (void)wheelDidChangeValue:(id)sender
{
    [self.nameCardDelegate updateNameCard:[self getRandomNameFor:[[[self class] firstLettersInNamesIcelandic] objectAtIndex:self.wheel.selectedIndex]]];
}





#pragma mark - SetNamesDatabaseDelegate

- (void)setNamesDatabase:(UIManagedDocument *)namesDatabase
{
    if( _namesDatabase != namesDatabase ) {
        _namesDatabase = namesDatabase;
        if( _namesDatabase ) {
            
            [self setupFetchRequest];
            [self fetchResults];
        }
    }
}


- (void)doEntityCounts {

    NSArray *firstLetters = [[self class] firstLettersInNamesIcelandic];
    _alphabetCounts = [[NSMutableDictionary alloc] init];
    for( NSString *oneLetter in firstLetters ) {
        
        NSPredicate *oneLetterPredicate = [_namesBeginningWithLetterPredicate predicateWithSubstitutionVariables:@{@"letter": oneLetter}];

        NSError *error = nil;
        
        _nameRequestCounts.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[oneLetterPredicate, _nameFilterPredicate]];
        
        NSUInteger oneFirstLetterCount = [_namesDatabase.managedObjectContext countForFetchRequest:_nameRequestCounts error:&error];
        
        // we'll create a key with the format: [first letter][gender]
        [_alphabetCounts setObject:[NSNumber numberWithUnsignedInteger:oneFirstLetterCount] forKey:[NSString stringWithFormat:@"%@%@", oneLetter, self.genderSelection]];
    }
}

- (void)setupFetchRequest {
    
    _nameRequestCounts = [[NSFetchRequest alloc] init];
    [_nameRequestCounts setEntity:[NSEntityDescription entityForName:@"Name" inManagedObjectContext:_namesDatabase.managedObjectContext]];
    
    _nameRequestSingleNames = [[NSFetchRequest alloc] init];
    [_nameRequestSingleNames setEntity:[NSEntityDescription entityForName:@"Name" inManagedObjectContext:_namesDatabase.managedObjectContext]];
}

- (void)setupFilterPredicate {
    
    NSMutableArray *predicateFormats = [NSMutableArray array];
    NSMutableArray *predicateArguments = [NSMutableArray array];
    
    NSString *popularitySortDescriptorKey;
    if( self.namesPosition == 0 ) {
        popularitySortDescriptorKey = @"countAsFirstName";
    } else {
        popularitySortDescriptorKey = @"countAsSecondName";
    }
        
    if( self.syllableCount > 0 ) {
        [predicateFormats addObject:@"countSyllables == %d"];
        [predicateArguments addObject:[NSNumber numberWithInt:self.syllableCount]];
    }
    if( self.icelandicLetterCount > -1 ) {
        [predicateFormats addObject:@"countIcelandicLetters == %d"];
        [predicateArguments addObject:[NSNumber numberWithInt:self.icelandicLetterCount]];
    }
    
    if( self.minPopularity > 0 ) {
        [predicateFormats addObject:[popularitySortDescriptorKey stringByAppendingString:@" >= %d"]];
        [predicateArguments addObject:[NSNumber numberWithInt:self.minPopularity]];
    }
    if( self.maxPopularity < MAX_TOTAL_NUMBER_OF_NAMES ) {
        [predicateFormats addObject:[popularitySortDescriptorKey stringByAppendingString:@" <= %d"]];
        [predicateArguments addObject:[NSNumber numberWithInt:self.maxPopularity]];
    }
    
    if( self.firstInitialFilter != nil && self.namesPosition == 0 ) {
        [predicateFormats addObject:@"name beginswith %@"];
        [predicateArguments addObject:self.firstInitialFilter];
    }
    if( self.secondInitialFilter != nil && self.namesPosition == 1 ) {
        [predicateFormats addObject:@"name beginswith %@"];
        [predicateArguments addObject:self.secondInitialFilter];
    }
    
    if( self.searchFilter != nil && [self.searchFilter length] > 0 ) {
        [predicateFormats addObject:@"name contains[c] %@"];
        [predicateArguments addObject:self.searchFilter];
    }
    
    if( self.genderSelection ) {
        [predicateFormats addObject:@"gender == %@"];
        [predicateArguments addObject:self.genderSelection];
    }
    
    if( [predicateArguments count] ) {
        _nameFilterPredicate = [NSPredicate predicateWithFormat:[predicateFormats componentsJoinedByString:@" AND "] argumentArray:predicateArguments];
    }
}


- (NSString *)getRandomNameFor:(NSString *)firstLetter {
    NSString *randomName;
    
    NSPredicate *firstLetterPredicate = [_namesBeginningWithLetterPredicate predicateWithSubstitutionVariables:@{@"letter": firstLetter}];
    
    NSError *error = nil;
    
    _nameRequestSingleNames.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[firstLetterPredicate, _nameFilterPredicate]];
    
    
    NSUInteger firstLetterNamesCount = [[_alphabetCounts objectForKey:[NSString stringWithFormat:@"%@%@", firstLetter, self.genderSelection]] unsignedIntegerValue];
    
    
    
    if( 0 < firstLetterNamesCount ) {
        
        NSUInteger offset = arc4random_uniform(firstLetterNamesCount);
        NSLog(@"offset: %d", offset);
        
        [_nameRequestSingleNames setFetchOffset:offset];
        [_nameRequestSingleNames setFetchLimit:1];
        
        
        // TODO: we might want to do a batch of db fetches (on a separate thread) and store the results in a queue
        //      which we'd fill up again as it nears empty.  See for example:
        //      http://stackoverflow.com/a/11223120/169858
        //      http://www.sebastianrehnby.com/blog/2013/05/20/using-background-fetching-with-core-data/
        // ...but for now we'll go directly to the db each time:
        
        NSArray *nameResult = [_namesDatabase.managedObjectContext executeFetchRequest:_nameRequestSingleNames error:&error];
        
        Name *nameManagedObject = nil;
        if( [nameResult count] ) {
            nameManagedObject = [nameResult lastObject];
            randomName = nameManagedObject.name;
        } else {
            randomName = @"";
        }
    } else {
        randomName = @"";
    }
    
    return randomName;
}



// from http://stackoverflow.com/a/20544805/169858
+ (NSArray *)firstLettersInNamesIcelandic
{
    static NSArray *_letters;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _letters = @[@"A",
                     @"Á",
                     @"B",
                     @"C",
                     @"D",
                     @"E",
                     @"F",
                     @"G",
                     @"H",
                     @"I",
                     @"Í",
                     @"J",
                     @"K",
                     @"L",
                     @"M",
                     @"N",
                     @"O",
                     @"Ó",
                     @"P",
                     @"R",
                     @"S",
                     @"T",
                     @"U",
                     @"Ú",
                     @"V",
                     @"W",
                     @"Y",
                     @"Ý",
                     @"Z",
                     @"Þ",
                     @"Æ",
                     @"Ö"];
    });
    return _letters;
}

@end
