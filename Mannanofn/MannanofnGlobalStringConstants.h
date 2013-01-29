//
//  MannanofnGlobalStringConstants.h
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 10/26/12.
//  Copyright (c) 2012 nemur.net. All rights reserved.
//

#ifndef Mannanofn_MannanofnGlobalStringConstants_h
#define Mannanofn_MannanofnGlobalStringConstants_h

#define ORDER_BY_NAME @"orderByName"
#define ORDER_BY_FIRST_NAME_POPULARITY @"orderByFirstNamePopularity"

#define GENDER_SELECTION_STORAGE_KEY @"selectedGender"
#define GENDER_FEMALE @"X"
#define GENDER_MALE @"Y"


// from http://stackoverflow.com/a/12447113
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )


#endif
