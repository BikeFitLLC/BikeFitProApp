//
//  LegAngleImageView.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 10/3/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "LegAngleImageView.h"

@implementation LegAngleImageView
{
    //UIBezierPath *anglePath;
    //UIBezierPath *arcPath;
    UIBezierPath *circle1;
    UIBezierPath *circle2;
    UIBezierPath *circle3;
    UIColor *brushPattern;
}
@synthesize path;
@synthesize arcPath;
@synthesize vertices;
@synthesize angle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#define pi 3.14159265359
#define   DEGREES_TO_RADIANS(degrees)  ((pi * degrees)/ 180)

- (void) calculateAngle
{
    CGPoint P2 = [[vertices objectAtIndex:0] CGPointValue];
    CGPoint P1 = [[vertices objectAtIndex:1] CGPointValue];
    CGPoint P3 = [[vertices objectAtIndex:2] CGPointValue];
    
    CGPoint A = CGPointMake(P2.x - P1.x, P2.y - P1.y);
    CGPoint B = CGPointMake(P3.x - P1.x, P3.y - P1.y);
    
    CGFloat dotAngle = atan2f(B.x * A.y -  A.x * B.y, A.x*B.x + A.y*B.y);
    
    angle = fabsf(dotAngle);
    clockwise = true;
    if( dotAngle > 0 )
    {
        clockwise = false;
    }
    //angle = angle * 57.2957795;
    //[angleLabel setCenter:P1];
    
    return;
    
}

- (void) drawAngle:(CGPoint)a b:(CGPoint)b c:(CGPoint)c
{
    if(!path)
    {
        path = [[UIBezierPath alloc] init];
        path.lineJoinStyle = kCGLineJoinRound;
    }
    [path removeAllPoints];
    [path moveToPoint:a];
    [path addLineToPoint:b];
    [path addLineToPoint:c];
    
    circle1 = [UIBezierPath bezierPathWithArcCenter:a radius:50 startAngle:0 endAngle:2*pi clockwise:YES];
    circle2 = [UIBezierPath bezierPathWithArcCenter:b radius:50 startAngle:0 endAngle:2*pi clockwise:YES];
    circle3 = [UIBezierPath bezierPathWithArcCenter:c radius:50 startAngle:0 endAngle:2*pi clockwise:YES];
    
    
    //Calculate and create an arc for the angle drawn above
    float startAngle = 0;
    
    CGPoint pointARelativeToB;
    pointARelativeToB.x = a.x - b.x;
    pointARelativeToB.y = b.y - a.y;
    float tanValue = fabsf(pointARelativeToB.x)/abs(pointARelativeToB.y);
    startAngle = atan(tanValue);

    if(pointARelativeToB.x >= 0  && pointARelativeToB.y >= 0)
    {
        startAngle = (3*pi/2) + startAngle;
    }
    
    if(pointARelativeToB.x < 0 && pointARelativeToB.y >=0)
    {
        startAngle = (3*pi/2) - startAngle;
    }
    if(pointARelativeToB.x >= 0 && pointARelativeToB.y < 0)
    {
        startAngle = pi/2 - startAngle;
        
    }
    if(pointARelativeToB.x < 0 && pointARelativeToB.y < 0)
    {
        startAngle = pi/2 + startAngle;
    }
    
    float endAngle  = startAngle + angle;
    
    
    if(!clockwise)
    {
        endAngle = startAngle - angle;
    }
    
    arcPath = [UIBezierPath bezierPathWithArcCenter:b radius:75
                                                  startAngle:startAngle
                                                    endAngle:endAngle
                                                   clockwise:clockwise];
    [self setNeedsDisplay];
    return;
}

- (void) clearAngle
{
    [path removeAllPoints];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    brushPattern = [UIColor yellowColor];
    path.LineWidth = 2;
    [brushPattern setStroke];
    [path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    
    UIColor *fillColor = [UIColor yellowColor];
    [fillColor setFill];

    float circleAlpha = .3;
    [circle1 strokeWithBlendMode:kCGBlendModeNormal alpha:circleAlpha];
    [circle1 fillWithBlendMode:kCGBlendModeNormal alpha:circleAlpha];
    
    [circle2 strokeWithBlendMode:kCGBlendModeNormal alpha:circleAlpha];
    [circle2 fillWithBlendMode:kCGBlendModeNormal alpha:circleAlpha];
    [circle3 strokeWithBlendMode:kCGBlendModeNormal alpha:circleAlpha];
    [circle3 fillWithBlendMode:kCGBlendModeNormal alpha:circleAlpha];
    
    
    arcPath.lineWidth = 2;
    float dashPattern[] = {5,5};
    [arcPath setLineDash:dashPattern count:2 phase:4.0];
    [arcPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
}

@end
