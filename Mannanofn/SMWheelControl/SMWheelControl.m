//
//  SMWheelControl.m
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.


#import "SMWheelControl.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kMinDistanceFromCenter = 30.0;
static const CGFloat kMaxVelocity = 20.0;
static const CGFloat kSMDecelerationMultiplier = 0.97;
static const CGFloat kMinDeceleration = 0.1;
static const CGFloat kSMSnappingAngleThreshold = 0.001;
static const CGFloat kSMAngleDeltaThreshold = 0.1;
static const CGFloat kSMDefaultSelectionVelocityMultiplier = 10.0;
static const CGFloat kSMZoomZoneThreshold = 1.50f;


@interface SMWheelControl ()

@property (nonatomic, strong) UIView *sliceContainer;

@property (nonatomic, assign) SMWheelControlStatus status;

@end


@implementation SMWheelControl {
    BOOL _detectingTap;
    CGFloat _animatingVelocity;
    CADisplayLink *_decelerationDisplayLink;
    CADisplayLink *_inertiaDisplayLink;
    CFTimeInterval _startTouchTime;
    CFTimeInterval _endTouchTime;
    CGFloat _startTouchAngle;
    CGFloat _previousTouchAngle;
    CGFloat _currentTouchAngle;
    CGFloat _snappingTargetAngle;
    CGFloat _snappingStep;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		
        [self drawWheel];
	}
    return self;
}

- (void)clearWheel
{
    for (UIView *subview in self.sliceContainer.subviews) {
        [subview removeFromSuperview];
    }
}

- (void)drawWheel
{
    self.sliceContainer = [[UIView alloc] initWithFrame:self.bounds];
    NSUInteger numberOfSlices = [self.dataSource numberOfSlicesInWheel:self];

    CGFloat angleSize = 2 * M_PI / numberOfSlices;

    CGFloat snappingAngle = [self.dataSource respondsToSelector:@selector(snappingAngleForWheel:)] ? [self.dataSource snappingAngleForWheel:self] : 0.0;

    for (int i = 0; i < numberOfSlices; i++) {

        UIView *sliceView = [self.dataSource wheel:self viewForSliceAtIndex:i];
        sliceView.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
        sliceView.layer.position = CGPointMake(self.sliceContainer.bounds.size.width / 2.0 - self.sliceContainer.frame.origin.x,
                                        self.sliceContainer.bounds.size.height / 2.0 - self.sliceContainer.frame.origin.y);
        sliceView.transform = CGAffineTransformMakeRotation(angleSize * i + snappingAngle);

        [self.sliceContainer addSubview:sliceView];
    }

    self.sliceContainer.userInteractionEnabled = NO;
    [self addSubview:self.sliceContainer];
    
    [self checkForSlicesInZoomZone];
}


- (void)didEndRotationOnSliceAtIndex:(NSUInteger)index
{
    _selectedIndex = index;
    if ([self.delegate respondsToSelector:@selector(wheelDidEndDecelerating:)]) {
        [self.delegate wheelDidEndDecelerating:self];
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


#pragma mark - Touches

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{    
    switch (_status) {
        case SMWheelControlStatusIdle:
            _detectingTap = YES;
            break;
            
        case SMWheelControlStatusDecelerating:
            [self endDecelerating];
            [self endSnapping];
            break;
            
        case SMWheelControlStatusSnapping:
            [self endSnapping];
            break;
            
        default:
            break;
    }

    CGPoint touchPoint = [touch locationInView:self];
    float dist = [self distanceFromCenter:touchPoint];

    if (dist < kMinDistanceFromCenter)
    {
        return NO;
    }

    _startTouchTime = _endTouchTime = CACurrentMediaTime();

	_startTouchAngle = _currentTouchAngle = _previousTouchAngle = [self angleForTouch:touch];

    return YES;
}


- (BOOL)continueTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    _detectingTap = NO;
 
    if (self.rotationDisabled) {
        return NO;
    }
    
    CGPoint point = [touch locationInView:self];

    _startTouchTime = _endTouchTime;
    _endTouchTime = CACurrentMediaTime();

    float dist = [self distanceFromCenter:point];

    if (dist < kMinDistanceFromCenter) {
        // Drag path too close to the center
        return YES;
    }

    _previousTouchAngle = _currentTouchAngle;
	_currentTouchAngle = [self angleForTouch:touch];

    CGFloat angleDelta = _currentTouchAngle - _previousTouchAngle;

    self.sliceContainer.transform = CGAffineTransformRotate(self.sliceContainer.transform, angleDelta);

    if ([self.delegate respondsToSelector:@selector(wheel:didRotateByAngle:)]) {
        [self.delegate wheel:self didRotateByAngle:(angleDelta)];
    }
    
    [self checkForSlicesInZoomZone];

    return YES;
}


- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_status == SMWheelControlStatusIdle && touch.tapCount > 0 && _detectingTap) {
        
        [self didReceiveTapAtAngle:[self angleForTouch:touch]];
        _detectingTap = NO;
        
    } else {
       [self beginDeceleration]; 
    }
}


#pragma mark - Inertia

- (void)beginDeceleration
{
    _animatingVelocity = [self velocity];

    if (_animatingVelocity != 0) {
        _status = SMWheelControlStatusDecelerating;
        [_decelerationDisplayLink invalidate];
        _decelerationDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(decelerationStep)];
        _decelerationDisplayLink.frameInterval = 1;
        [_decelerationDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
    } else {
        [self snapToNearestSlice];
    }
}


- (void)decelerationStep
{
    CGFloat newVelocity = _animatingVelocity * kSMDecelerationMultiplier;

    CGFloat angle = _animatingVelocity / 60.0;

    if (newVelocity <= kMinDeceleration && newVelocity >= -kMinDeceleration) {
        [self endDecelerating];
        
    } else {
        _animatingVelocity = newVelocity;

        self.sliceContainer.transform = CGAffineTransformRotate(self.sliceContainer.transform, -angle);

        if ([self.delegate respondsToSelector:@selector(wheel:didRotateByAngle:)]) {
            [self.delegate wheel:self didRotateByAngle:-angle];
        }
        
        [self checkForSlicesInZoomZone];
    }
}


- (void)endDecelerating
{
    [_decelerationDisplayLink invalidate];
    [self snapToNearestSlice];
}


#pragma mark - Snapping

- (void)snapToNearestSlice
{
    _status = SMWheelControlStatusSnapping;
    
    CGFloat currentAngle = atan2f(self.sliceContainer.transform.b, self.sliceContainer.transform.a);

    NSUInteger numberOfSlices = [self.dataSource numberOfSlicesInWheel:self];
    CGFloat radiansPerSlice = 2.0 * M_PI / numberOfSlices;
    int closestSlice = round(currentAngle / radiansPerSlice);

    [self selectSliceAtIndex:closestSlice animated:YES];
}


- (void)snappingStep
{
    CGFloat currentAngle = atan2f(self.sliceContainer.transform.b, self.sliceContainer.transform.a);
    
    CGFloat difference = atan2(sin(_snappingTargetAngle - currentAngle), cos(_snappingTargetAngle - currentAngle));
    
    if (fabsf(difference) <= kSMSnappingAngleThreshold) {
        [self endSnapping];
    } else {
        currentAngle += _snappingStep;
        self.sliceContainer.transform = CGAffineTransformMakeRotation(currentAngle);
        
        if ([self.delegate respondsToSelector:@selector(wheel:didRotateByAngle:)]) {
            [self.delegate wheel:self didRotateByAngle:_snappingStep];
        }
        
        [self checkForSlicesInZoomZone];
    }
}


- (void)endSnapping
{
    CGFloat currentAngle = atan2f(self.sliceContainer.transform.b, self.sliceContainer.transform.a);
    NSUInteger numberOfSlices = [self.dataSource numberOfSlicesInWheel:self];
    CGFloat radiansPerSlice = 2.0 * M_PI / numberOfSlices;
    CGFloat snappingAngle = [self.dataSource respondsToSelector:@selector(snappingAngleForWheel:)] ? [self.dataSource snappingAngleForWheel:self] : 0.0;
    int index = (lroundf((- (M_PI / 2) + snappingAngle - currentAngle) / radiansPerSlice) + numberOfSlices) % numberOfSlices;
    
    [self didEndRotationOnSliceAtIndex:index];
    
    [_inertiaDisplayLink invalidate];
    _status = SMWheelControlStatusIdle;
}


#pragma mark - Accessory methods

- (CGFloat)angleForTouch:(UITouch *)touch
{
    CGPoint touchPoint = [touch locationInView:self];
    float dx = touchPoint.x - self.sliceContainer.center.x;
    float dy = touchPoint.y - self.sliceContainer.center.y;
    return atan2f(dy, dx);
}


- (void)didReceiveTapAtAngle:(CGFloat)angle
{
    if ([self.delegate respondsToSelector:@selector(wheel:didTapOnSliceAtIndex:)]) {
        
        CGFloat currentAngle = atan2f(self.sliceContainer.transform.b, self.sliceContainer.transform.a);
        NSUInteger numberOfSlices = [self.dataSource numberOfSlicesInWheel:self];
        CGFloat radiansPerSlice = 2.0 * M_PI / numberOfSlices;
        CGFloat snappingAngle = [self.dataSource respondsToSelector:@selector(snappingAngleForWheel:)] ? [self.dataSource snappingAngleForWheel:self] : 0.0;
        int index = (lroundf((angle + snappingAngle - currentAngle) / radiansPerSlice) + numberOfSlices) % numberOfSlices;
        
        [self.delegate wheel:self didTapOnSliceAtIndex:index];
    }
}


- (void)selectSliceAtIndex:(NSInteger)index animated:(BOOL)animated
{
    NSUInteger numberOfSlices = [self.dataSource numberOfSlicesInWheel:self];
    CGFloat currentAngle = atan2f(self.sliceContainer.transform.b, self.sliceContainer.transform.a);
    CGFloat radiansPerSlice = 2.0 * M_PI / numberOfSlices;
    
    _snappingTargetAngle = (CGFloat)index * radiansPerSlice;
    
    if (_snappingTargetAngle - currentAngle > M_PI) {
        _snappingTargetAngle -= 2.0 * M_PI;
    } else if (_snappingTargetAngle - currentAngle < -M_PI) {
        _snappingTargetAngle += 2.0 * M_PI;
    }

    if (currentAngle != _snappingTargetAngle) {
        _snappingStep = (_snappingTargetAngle - currentAngle) / kSMDefaultSelectionVelocityMultiplier;
    } else {
        return;
    }

    _status = SMWheelControlStatusSnapping;
    [_inertiaDisplayLink invalidate];
    _inertiaDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(snappingStep)];
    _inertiaDisplayLink.frameInterval = 1;
    [_inertiaDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)checkForSlicesInZoomZone
{
    CGFloat currentAngle = atan2f(self.sliceContainer.transform.b, self.sliceContainer.transform.a);
    NSUInteger numberOfSlices = [self.dataSource numberOfSlicesInWheel:self];
    CGFloat radiansPerSlice = (2.0 * M_PI) / numberOfSlices;
    
    for (NSUInteger i = 0; i < numberOfSlices; i++) {
        CGFloat sliceAngleRad = 0;
        sliceAngleRad = fmod((currentAngle + fmod((radiansPerSlice * i), M_PI * 2)), M_PI * 2);
        
        CGFloat diff = atan2(sin(sliceAngleRad), cos(sliceAngleRad));;
        
        if (fabsf(diff) < kSMZoomZoneThreshold) {
            if ([self.delegate respondsToSelector:@selector(wheel:sliceAtIndex:isInZoomZoneWithDeltaAngle:)]) {
                [self.delegate wheel:self sliceAtIndex:i isInZoomZoneWithDeltaAngle:diff];
            }
        }
    }
}

- (CGFloat)velocity
{
    CGFloat velocity = 0.0;

    if (_endTouchTime != _startTouchTime && fabsf(_previousTouchAngle - _currentTouchAngle) >= kSMAngleDeltaThreshold) {
        velocity = (_previousTouchAngle - _currentTouchAngle) / (CGFloat)(_endTouchTime - _startTouchTime);
    }

    if (velocity > kMaxVelocity) {
        velocity = kMaxVelocity;
    } else if (velocity < -kMaxVelocity) {
        velocity = -kMaxVelocity;
    }

    return velocity;
}


- (float)distanceFromCenter:(CGPoint)point
{
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
    float dx = point.x - center.x;
    float dy = point.y - center.y;
    return sqrt(dx * dx + dy * dy);
}


- (void)reloadData
{
    [self clearWheel];
    [self drawWheel];
}

- (void)invalidateDisplayLinks
{
    [_decelerationDisplayLink invalidate];
    _decelerationDisplayLink = nil;
    
    [_inertiaDisplayLink invalidate];
    _inertiaDisplayLink = nil;
}

#pragma mark - selectedIndex Setter

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    [self selectSliceAtIndex:-selectedIndex animated:animated];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

@end
