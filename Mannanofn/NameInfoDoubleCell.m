//
//  NameInfoDoubleCell.m
//  Mannanofn
//
//  Created by Björn Þór Jónsson on 01/09/14.
//  Copyright (c) 2014 nemur.net. All rights reserved.
//

#import "NameInfoDoubleCell.h"

@implementation NameInfoDoubleCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (IBAction)toggleFavorite:(id)sender {
    
    [self.btnToggleFavorite setImage:[self.favoriteToggleDelegate toggleFavoriteForName:self.name.text gender:self.gender] forState:UIControlStateNormal];
}


@end
