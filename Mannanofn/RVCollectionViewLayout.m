//
//  RVCollectionViewLayout.m
//  RouletteViewDemo
//
//  Created by Kenny Tang on 3/16/13.
//  Copyright (c) 2013 Kenny Tang. All rights reserved.
//  see:  http://corgitoergosum.net/2013/03/16/from-js-to-uicollectionview-building-a-custom-roulette-wheel-stack-control-in-ios/
//
//  Modified by Björn Þór Jónsson on 20/8/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "RVCollectionViewLayout.h"
//#import "RVCollectionViewCell.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define ROTATION_TONING_FRACTION 1
#define ROTATION_TONING_MULTIPLE 1

#define CARD_Y_LIFT 80.0f

#define STACK_OVERLAP 120


//#define RANGE_FROM_MIN -122
//#define RANGE_FROM_MAX 258

#define RANGE_FROM_MIN -570
#define RANGE_FROM_MAX 700

//#define RANGE_FROM_MIN -500
//#define RANGE_FROM_MAX 700


@implementation RVCollectionViewLayout

-(id)init
{
    if (!(self = [super init])) return nil;
/*
    self.itemSize = CGSizeMake(100.0f, 153.0f);
    self.sectionInset = UIEdgeInsetsMake(0, 60, 0, 60);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
*/
    [self initializeLayoutCards];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
/*
        self.itemSize = CGSizeMake(100.0f, 153.0f);
        self.sectionInset = UIEdgeInsetsMake(0, 60, 0, 60);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
*/
        [self initializeLayoutCards];
    }
    return self;
}

- (void)prepareLayout {
    self.superView = self.collectionView.superview;
}

- (void)initializeLayoutCards {
    
//    self.itemSize = CGSizeMake(230.0f, 340.0f);
//    self.sectionInset = UIEdgeInsetsMake(0, 60, 0, 60);
//    self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);

//    self.itemSize = CGSizeMake(100.0f, 153.0f);

//    self.itemSize = CGSizeMake(198.0f, 296.0f);
    self.itemSize = CGSizeMake(260.0f, 420.0f);

    self.sectionInset = UIEdgeInsetsMake(0, 60, 0, 60);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.minimumInteritemSpacing = 0;
}

/*
-(CGSize)collectionViewContentSize
{
    NSInteger xSize = [self.collectionView numberOfItemsInSection:0]
    * self.itemSize.width;
    NSInteger ySize = [self.collectionView numberOfSections]
    * (self.itemSize.height);
    
    CGSize contentSize = CGSizeMake(xSize, ySize);
    
    if (self.collectionView.bounds.size.width > contentSize.width)
        contentSize.width = self.collectionView.bounds.size.width;
    
    if (self.collectionView.bounds.size.height > contentSize.height)
        contentSize.height = self.collectionView.bounds.size.height;
    
    return contentSize;
}
*/
 
/**
This method is called by UICollectionView for laying out cells in the visible rect.
 */

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray * array = [super layoutAttributesForElementsInRect:rect];
    
    NSMutableArray * modifiedLayoutAttributesArray = [NSMutableArray array];
    
    CGFloat horizontalCenter = (CGRectGetWidth(self.collectionView.bounds));
//horizontalCenter = 180.0f;
    [array enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * layoutAttributes, NSUInteger idx, BOOL *stop) {
/*
        CGFloat xCenterPosition = layoutAttributes.center.x;
        CGFloat yCenterPosition = layoutAttributes.center.y;
        if( layoutAttributes.indexPath.row != 0 ) {
            xCenterPosition -= STACK_OVERLAP * layoutAttributes.indexPath.row;
//            xCenterPosition -= STACK_OVERLAP;
        }
        layoutAttributes.center = CGPointMake(xCenterPosition, yCenterPosition);
*/
//        NSLog(@"center: %@", NSStringFromCGPoint(layoutAttributes.center));

        
        CGPoint pointInCollectionView = layoutAttributes.frame.origin;
        CGPoint pointInMainView = [self.superView convertPoint:pointInCollectionView fromView:self.collectionView];
        
        CGPoint centerInCollectionView = layoutAttributes.center;
        CGPoint centerInMainView = [self.superView convertPoint:centerInCollectionView fromView:self.collectionView];
        
        
        float rotateBy = 0.0f;
//        CGPoint translateBy = CGPointZero;
        
        // we find out where this cell is relative to the center of the viewport,
        // and invoke private methods to deduce the amount of rotation to apply
        if (pointInMainView.x < self.collectionView.frame.size.width+80.0f){
//            translateBy = [self calculateTranslateBy:horizontalCenter attribs:layoutAttributes];

//            NSLog(@"pointInMainView: %@", NSStringFromCGPoint(pointInMainView));
//            NSLog(@"centerInMainView: %@", NSStringFromCGPoint(centerInMainView));
            
            // divide by 2 to lessen the rotation for large items
            rotateBy = [self calculateRotationFromViewPortDistance:pointInMainView.x center:horizontalCenter];
/*
            if( pointInMainView.x < RANGE_FROM_MIN || pointInMainView.x > RANGE_FROM_MAX ) {
                NSLog(@"rotate from %f - by: %f", pointInMainView.x, rotateBy);
            }
*/
            
            CGPoint rotationPoint = CGPointMake(self.collectionView.frame.size.width/2, self.collectionView.frame.size.height);
            
            
            
            // there are two transforms and one rotation. this is needed to make the view appear to have rotated around
            // a certain point.

            CATransform3D transform = CATransform3DIdentity;
            
            // let's translate the cell closer to the horizontal center by half it's current distance to the center
//            transform = CATransform3DTranslate(transform, (horizontalCenter - pointInMainView.x) / 2, 0.0, 0.0);

            transform = CATransform3DTranslate(transform, rotationPoint.x - centerInMainView.x, rotationPoint.y - centerInMainView.y, 0.0);
            transform = CATransform3DRotate(transform, DEGREES_TO_RADIANS(-rotateBy), 0.0, 0.0, -1.0);
            
            // -30.0f to lift the cards up a bit
            // bring the cells closer together, overlapping, by dividing the x movement back by 2
            transform = CATransform3DTranslate(transform, (centerInMainView.x - rotationPoint.x) / 3, centerInMainView.y-rotationPoint.y - CARD_Y_LIFT, 0.0);
            
            layoutAttributes.transform3D = transform;

            // right card is always on top
            layoutAttributes.zIndex = layoutAttributes.indexPath.item;
            

            [modifiedLayoutAttributesArray addObject:layoutAttributes];
        }
    }];
    return modifiedLayoutAttributesArray;
}



-(float)calculateRotationFromViewPortDistance:(float)x center:(float)horizontalCenter{
    
    float rotateByDegrees = [self remapNumbersToRange:x fromMin:RANGE_FROM_MIN fromMax:RANGE_FROM_MAX toMin:-35 toMax:35];
    return rotateByDegrees;
}

/*
 Linear equation for translating one range to another
 */
- (float)remapNumbersToRange:(float)inputNumber fromMin:(float)fromMin fromMax:(float)fromMax toMin:(float)toMin toMax:(float)toMax {
    return (inputNumber - fromMin) / (fromMax - fromMin) * (toMax - toMin) + toMin;
}

/*
-(CGPoint)calculateTranslateBy:(CGFloat)horizontalCenter attribs:(UICollectionViewLayoutAttributes *) layoutAttributes{
    
    float translateByY = -layoutAttributes.frame.size.height/2.0f;
    float distanceFromCenter = layoutAttributes.center.x - horizontalCenter;
    float translateByX = 0.0f;
    
    if (distanceFromCenter < 1){
        translateByX = -1 * distanceFromCenter;
    }else{
        translateByX = -1 * distanceFromCenter;
    }
    return CGPointMake(distanceFromCenter, translateByY);
    
}
*/



/*
 http://stackoverflow.com/questions/13749401/stopping-the-scroll-in-a-uicollectionview
 */

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
    CGFloat offsetAdjustment = CGFLOAT_MAX;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 1.4f);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x,
                                   0.0f, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat distanceFromCenter = layoutAttributes.center.x - horizontalCenter;
        if (ABS(distanceFromCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = distanceFromCenter;
        }
    }
    
    CGPoint offsetPoint = CGPointMake(
                                      proposedContentOffset.x + offsetAdjustment,
                                      proposedContentOffset.y);
    
//    NSLog(@"offsetPoint: %@", NSStringFromCGPoint(offsetPoint));
    NSLog(@"offsetAdjustment: %f", offsetAdjustment);
    
    return offsetPoint;
}



- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end

