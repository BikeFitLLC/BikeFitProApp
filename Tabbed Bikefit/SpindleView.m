//
//  SpindleView.m
//  bikefit
//
//  Created by Alfonso Lopez on 2/26/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "SpindleView.h"

@implementation SpindleView
@synthesize spindleYPosition;
@synthesize boxPath;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    //spindleYPosition = 300.0;
    // Drawing code
    boxPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 397, 768, 120 )];
    [boxPath moveToPoint:CGPointMake(0, spindleYPosition)];
    [boxPath addLineToPoint:CGPointMake(770, spindleYPosition)];
    
    UIColor *brushPattern = [UIColor redColor];
    [brushPattern setStroke];
    [boxPath stroke];
}


@end