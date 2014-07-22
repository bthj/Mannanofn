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


@interface WheelRandomController () <SetNamesDatabaseDelegate>

@property (strong, nonatomic) NamesDatabaseSetupUtility *namesDatabaseSetup;
@property (nonatomic, strong) UIManagedDocument *namesDatabase;

@property (nonatomic, strong) NSMutableDictionary *alphabetCounts;
@property (nonatomic, strong) NSPredicate *namesBeginningWithLetterPredicate;

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
    
    _namesBeginningWithLetterPredicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH $letter AND gender == $onegender"];
    
    // DB initialization
    self.namesDatabaseSetup = [[NamesDatabaseSetupUtility alloc] initNamesDatabaseForView:self.view];
    self.namesDatabaseSetup.fetchedResultsSetupDelegate = self;
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



#pragma mark - SetNamesDatabaseDelegate

- (void)setNamesDatabase:(UIManagedDocument *)namesDatabase
{
    if( _namesDatabase != namesDatabase ) {
        _namesDatabase = namesDatabase;
        if( _namesDatabase ) {
            [self doEntityCounts];
        }
    }
}


- (void)doEntityCounts {
    
    NSFetchRequest *nameRequest = [[NSFetchRequest alloc] init];
    [nameRequest setEntity:[NSEntityDescription entityForName:@"Name" inManagedObjectContext:_namesDatabase.managedObjectContext]];
    
    NSArray *firstLetters = [[self class] firstLettersInNamesIcelandic];
    _alphabetCounts = [[NSMutableDictionary alloc] init];
    for( NSString *oneLetter in firstLetters ) {
        
        NSPredicate *oneLetterMalePredicate = [_namesBeginningWithLetterPredicate predicateWithSubstitutionVariables:@{@"letter": oneLetter, @"onegender": GENDER_MALE}];
        NSPredicate *oneLetterFemalePredicate = [_namesBeginningWithLetterPredicate predicateWithSubstitutionVariables:@{@"letter": oneLetter, @"onegender": GENDER_FEMALE}];
        
        NSError *error = nil;
        
        // let's count the names begining with the given oneLetter for the male gender
        nameRequest.predicate = oneLetterMalePredicate;
        NSUInteger oneMaleFirstLetterCount = [_namesDatabase.managedObjectContext countForFetchRequest:nameRequest error:&error];
        // we'll create a key with the format: [first letter][gender]
        [_alphabetCounts setObject:[NSNumber numberWithUnsignedInteger:oneMaleFirstLetterCount] forKey:[NSString stringWithFormat:@"%@%@", oneLetter, GENDER_MALE]];
        
        // and for the female gender:
        nameRequest.predicate = oneLetterFemalePredicate;
        NSUInteger oneFemaleFirstLetterCount = [_namesDatabase.managedObjectContext countForFetchRequest:nameRequest error:&error];
        // we'll create a key with the format: [first letter][gender]
        [_alphabetCounts setObject:[NSNumber numberWithUnsignedInteger:oneFemaleFirstLetterCount] forKey:[NSString stringWithFormat:@"%@%@", oneLetter, GENDER_FEMALE]];
        
        
        if( [oneLetter isEqualToString:@"B"] ) {
            self.labelCount.text = [NSString stringWithFormat:@"%d",oneFemaleFirstLetterCount];
        }
    }
}


- (IBAction)pickRandom:(id)sender {
    
    NSString *firstLetter = @"B";
    NSString *gender = GENDER_FEMALE;

    NSFetchRequest *nameRequest = [[NSFetchRequest alloc] init];
    [nameRequest setEntity:[NSEntityDescription entityForName:@"Name" inManagedObjectContext:_namesDatabase.managedObjectContext]];
    
    NSPredicate *oneLetterPredicate = [_namesBeginningWithLetterPredicate predicateWithSubstitutionVariables:@{@"letter": firstLetter, @"onegender": gender}];
    
    NSUInteger firstLetterNamesCount = [[_alphabetCounts objectForKey:[NSString stringWithFormat:@"%@%@", firstLetter, gender]] unsignedIntegerValue];
    
    NSUInteger offset = firstLetterNamesCount - (arc4random() % firstLetterNamesCount);
    NSLog(@"offset: %d", offset);
    
    nameRequest.predicate = oneLetterPredicate;
    [nameRequest setFetchOffset:offset];
    [nameRequest setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *nameResult = [_namesDatabase.managedObjectContext executeFetchRequest:nameRequest error:&error];
    
    Name *nameManagedObject = nil;
    if( [nameResult count] ) {
        nameManagedObject = [nameResult lastObject];
        self.labelCount.text = nameManagedObject.name;
    }
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
                     @"É",
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
                     @"Q",
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
