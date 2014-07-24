//
// Created by Simone Civetta on 6/4/13.
//


#import <Foundation/Foundation.h>


@class SMWheelControl;

/**
 *  The data source responsible for pouplating the objects of the rotating wheel
 */
@protocol SMWheelControlDataSource <NSObject>

@required

/**
 *  Returns the view of the slice at the specified index.
 *
 *  @param wheel A wheel control object requesting the cell.
 *  @param index An index locating a row in the cheel control
 *
 *  @return A view that the wheel control can use for the specified slice.
 */
- (UIView *)wheel:(SMWheelControl *)wheel viewForSliceAtIndex:(NSUInteger)index;

/**
 *  Tells the data source to return the number of slices.
 *
 *  @param wheel A wheel control object requesting the information.
 *
 *  @return The number of slices in the wheel.
 */
- (NSUInteger)numberOfSlicesInWheel:(SMWheelControl *)wheel;


@optional

/**
 *  Returns the angle the rotation should snap to.
 *
 *  @param wheel A wheel control object requesting the information.
 *
 *  @return The snapping angle, expressed in radians. 
 */
- (CGFloat)snappingAngleForWheel:(SMWheelControl *)wheel;

@end
