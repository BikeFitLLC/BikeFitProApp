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
    self.overlayPath = [[UIBezierPath alloc] init];
    self.overlayPath.LineWidth = 3;
    
    //Add the dragging circle
    UIBezierPath *anglePath = [[UIBezierPath alloc] init];
    [anglePath moveToPoint:startPointLocation];
    [anglePath addLineToPoint:endPointLocation];
    
    [anglePath appendPath:[UIBezierPath bezierPathWithArcCenter:endPointLocation
                                                            radius:30
                                                            startAngle:0
                                                            endAngle:2*3.141597
                                                            clockwise:YES]];
    
    CGPoint startPoint;
    startPoint.x = self.bounds.size.width /2;
    startPoint.y = 0;
    
    [self.overlayPath moveToPoint:startPoint];
    CGPoint newPoint;
    CGFloat laserLength = 1500.0;
    newPoint.x = startPoint.x;
    newPoint.y = laserLength;
    [self.overlayPath addLineToPoint:newPoint];
    
    //[self.overlayPath moveToPoint:CGPointMake(0, barYPosition)];
    //[self.overlayPath addLineToPoint:CGPointMake(768, barYPosition)];
    
    [self.overlayPath appendPath:[UIBezierPath bezierPathWithRect:[self getBarDragRect]]];

    [self.overlayPath appendPath:anglePath];
    
    UIColor *brushPattern = [UIColor redColor];
    [brushPattern setStroke];
    //[self.overlayPath stroke];
    [super drawRect:rect];
}

///////////////////////////////////
//returns a rect in the current view that represents the drag box
///////////////////////////////////
-(CGRect)getBarDragRect
{
    return CGRectMake(startPointLocation.x, startPointLocation.y, 50, 100);
}


@end
