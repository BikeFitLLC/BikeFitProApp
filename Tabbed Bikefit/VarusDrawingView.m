//
//  VarusDrawingView.m
//  bikefit
//
//  Created by Alfonso Lopez on 2/24/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "VarusDrawingView.h"

@implementation VarusDrawingView
@synthesize endPointLocation;
@synthesize startPointLocation;
@synthesize barYPosition;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
  
    
    //Setup the lazer line
    //drawingView.overlayPath = [[UIBezierPath alloc] init];
    //drawingView.overlayPath.lineWidth = 3;
    
    //Add the dragging circle
    overlayPath = [[UIBezierPath alloc] init];
    [overlayPath moveToPoint:startPointLocation];
    [overlayPath addLineToPoint:endPointLocation];
    
    
    CGPoint startPoint;
    startPoint.x = self.frame.size.width /2;
    startPoint.y = 0;
    
    [overlayPath moveToPoint:startPoint];
    CGPoint newPoint;
    CGFloat laserLength = 1500.0;
    newPoint.x = startPoint.x;
    newPoint.y = laserLength;
    [overlayPath addLineToPoint:newPoint];
    
    //[self.overlayPath moveToPoint:CGPointMake(0, barYPosition)];
    //[self.overlayPath addLineToPoint:CGPointMake(768, barYPosition)];
    
    UIColor *brushPattern = [UIColor redColor];
    [brushPattern setStroke];
    [overlayPath stroke];
    [super drawRect:rect];
}



@end
