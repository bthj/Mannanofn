//
//  UILabel+VAlign.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 5/21/13.
//  Copyright (c) 2013 Síminn. All rights reserved.
//

#import "UILabel+VAlign.h"

@implementation UILabel (VAlign)

- (void) setVerticalAlignmentTop  // http://stackoverflow.com/a/6806975/169858
{
    CGSize textSize = [self.text sizeWithFont:self.font
                            constrainedToSize:self.frame.size
                                lineBreakMode:self.lineBreakMode];
    
    CGRect textRect = CGRectMake(self.frame.origin.x,
                                 self.frame.origin.y,
                                 self.frame.size.width,
                                 textSize.height);
    [self setFrame:textRect];
    [self setNeedsDisplay];
}

@end
