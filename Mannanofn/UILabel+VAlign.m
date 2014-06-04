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

- (void)alignTop {  // http://webcache.googleusercontent.com/a/20234746
    CGSize fontSize = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    CGRect rect = [self.text boundingRectWithSize:CGSizeMake(finalWidth, finalHeight) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:self.font} context:nil];
    CGSize theStringSize = rect.size;
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    for(int i=0; i< newLinesToPad; i++)
        self.text = [self.text stringByAppendingString:@" \n"];
}

@end
