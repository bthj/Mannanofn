//
//  NameInfoCell.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 21/08/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "NameInfoCell.h"


@implementation NameInfoCell

@synthesize contentView = _contentView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
/*
        [self.layer setShadowOffset:CGSizeMake(0, 2)];
        [self.layer setShadowRadius:1.0];
        [self.layer setShadowColor:[UIColor redColor].CGColor] ;
        [self.layer setShadowOpacity:0.5];
        [self.layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.bounds] CGPath]];
*/      
    }
    return self;
}

/*
- (void)setContentView:(UIView *)contentView {
    
    _contentView = contentView;
//    [self addSubview:contentView];
}
*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
