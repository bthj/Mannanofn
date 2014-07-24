//
//  XBWheelControl.h
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.


#import <UIKit/UIKit.h>
#import "SMWheelControlDelegate.h"
#import "SMWheelControlDataSource.h"


typedef enum {
    SMWheelControlStatusIdle,
    SMWheelControlStatusDecelerating,
    SMWheelControlStatusSnapping
} SMWheelControlStatus;


@protocol SMWheelControlDataSource;

/**
 *  SMWheelControl is a control for selecting an element by spinning a rotating wheel
 */
@interface SMWheelControl : UIControl

/**
 *  The delegate responsible for receiving the actions operated by the user on the control
 */
@property (nonatomic, weak) id <SMWheelControlDelegate> delegate;

/**
 *  The data source used to populate the control
 */
@property (nonatomic, weak) id <SMWheelControlDataSource> dataSource;

/**
 *  The currently selected index
 */
@property (nonatomic, assign) NSUInteger selectedIndex;

/**
 *  The current status of the wheel
 */
@property (nonatomic, assign, readonly) SMWheelControlStatus status;

/**
 *  Enables or disables the rotation gestures on the control
 */
@property (nonatomic, assign) BOOL rotationDisabled;

/**
 *  Reloads the data
 */
- (void)reloadData;

/**
 *  Programmatically sets the selected index
 *
 *  @param selectedIndex The index that should be selected
 *  @param animated      Animates the selection
 */
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

/**
 *  Invalidates the display link
 */
- (void)invalidateDisplayLinks;

@end
