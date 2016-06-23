//
//  DrawingView.m
//  bikefit
//
//  Created by Alfonso Lopez on 6/30/15.
//  Copyright (c) 2015 Alfonso Lopez. All rights reserved.
//

#import "DrawingView.h"

@implementation DrawingView
{
    UIColor *brushPattern;
}
@synthesize overlayPath;


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    brushPattern = [UIColor yellowColor];
    [brushPattern setStroke];
    overlayPath.lineWidth = 2;
    
    [overlayPath stroke];
    
    
}


@end
