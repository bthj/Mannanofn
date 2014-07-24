//
//  SMWheelControlDelegate.h
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.


#import <Foundation/Foundation.h>

@class SMWheelControl;

/**
 *  The delegate of a SMWheelControl object must adopt the SMWheelControlDelegate protocol. 
 *  Optional methods of the protocol allow the delegate to manage selections, rotations and deceleration.
 */
@protocol SMWheelControlDelegate <NSObject>

@optional

/**
 *  Tells the delegate that the wheel did end decelerating. 
 *
 *  @param wheel The wheel control object informing the delegate of this event.
 */
- (void)wheelDidEndDecelerating:(SMWheelControl *)wheel;

/**
 *  Tells the delegate that the wheel did rotate by the specified angle.
 *
 *  @param wheel The wheel control object informing the delegate of this event.
 *  @param angle The angle of rotation, expressed in radians.
 */
- (void)wheel:(SMWheelControl *)wheel didRotateByAngle:(CGFloat)angle;

/**
 *  Tells the delegate that the specified slice have been tapped.
 *
 *  @param wheel The wheel control object informing the delegate of this event.
 *  @param index The index that has been tapped.
 */
- (void)wheel:(SMWheelControl *)wheel didTapOnSliceAtIndex:(NSUInteger)index;

/**
 *  <#Description#>
 *
 *  @param wheel      The wheel control object informing the delegate of this event.
 *  @param index      The index that is in the zoom zone.
 *  @param deltaAngle <#deltaAngle description#>
 */
- (void)wheel:(SMWheelControl *)wheel sliceAtIndex:(NSUInteger)index isInZoomZoneWithDeltaAngle:(CGFloat)deltaAngle;

@end
