//
//  MannanofnGlobalStringConstants.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 10/26/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#ifndef Mannanofn_MannanofnGlobalStringConstants_h
#define Mannanofn_MannanofnGlobalStringConstants_h

#define FIRST_RUN_GUIDE_BEEN_DISMISSED_FOR_VERSION @"firstRunGuideBeenDismissedForVersion"

#define NAMES_READ_FROM_SEED_AT_VERSION @"namesReadFromSeedAtVersion"
#define NUMER_OF_ROWS_IN_POPULARITY_SECTION 10

#define ORDER_BY_NAME @"orderByName"
#define ORDER_BY_FIRST_NAME_POPULARITY @"orderByFirstNamePopularity"

#define GENDER_SELECTION_STORAGE_KEY @"selectedGender"
#define GENDER_FEMALE @"X"
#define GENDER_MALE @"Y"

#define SYLLABLES_COUNT_STORAGE_KEY @"showNamesWithNumberOfSyllables"
#define ICELANDIC_LETTER_COUNT_STORAGE_KEY @"showNamesWithNumberOfIcelandicLetters"
#define MIN_POPULARITY_STORAGE_KEY @"minimumPopularityFilter"
#define MAX_POPULARITY_STORAGE_KEY @"maximumPopularityFilter"
#define INITIAL_FIRST_STORAGE_KEY @"firstInitialToFilterBy"
#define INITIAL_SECOND_STORAGE_KEY @"secondInitialToFilterBy"
#define SEARCH_STRING_STORAGE_KEY @"searchStringToFilterBy"

#define SURNAME_STORAGE_KEY @"surname"

#define ADS_ON @"adsOn"

#define MAX_TOTAL_NUMBER_OF_NAMES 5500


#define PRODUCT_IDENTIFIER__FILTERS @"net.nemur.nefna.filters"
#define ENABLE_FILTERS_KEY @"enable_filters"

#define NOTIFICATION_PURCHASED_FILTERS @"notificationPurchasedFilters"


// from http://stackoverflow.com/a/12447113
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )


#endif
