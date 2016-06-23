//
//  LegAngleImageView.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 10/3/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "GoniometerDrawingView.h"

@implementation GoniometerDrawingView
{
    UIColor *brushPattern;
}
@synthesize drawKneePath;
@synthesize drawShoulderPath;
@synthesize drawHipPath;

@synthesize kneePath;
@synthesize shoulderPath;
@synthesize hipPath;

@synthesize kneeVertices;
@synthesize shoulderVertices;
@synthesize hipVertices;

@synthesize kneeAngle;
@synthesize shoulderAngle;
@synthesize hipAngle;


- (id)initWithFrame:(CGRect)frame image:(UIImage *)imageToShow
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDrawKneePath: true];
    }
    return self;
}

#define pi 3.14159265359
#define   DEGREES_TO_RADIANS(degrees)  ((pi * degrees)/ 180)

- (CGFloat) calculateAngleForPoints:(CGPoint)a b:(CGPoint)b c:(CGPoint)c
{
    CGPoint P2 = a;
    CGPoint P1 = b;
    CGPoint P3 = c;
    
    CGPoint A = CGPointMake(P2.x - P1.x, P2.y - P1.y);
    CGPoint B = CGPointMake(P3.x - P1.x, P3.y - P1.y);
    
    CGFloat dotAngle = atan2f(B.x * A.y -  A.x * B.y, A.x*B.x + A.y*B.y);
    
    CGFloat angle = fabsf(dotAngle);
    clockwise = true;
    if( dotAngle > 0 )
    {
        clockwise = false;
    }
    //angle = angle * 57.2957795;
    //[angleLabel setCenter:P1];
    
    return angle;
    
}

- (UIBezierPath*) drawAngleWithPoints:(CGPoint)a b:(CGPoint)b c:(CGPoint)c andColor:(UIColor*)color
{
    UIBezierPath *anglePath = [[UIBezierPath alloc] init];

    [anglePath moveToPoint:a];
    [anglePath addLineToPoint:b];
    [anglePath addLineToPoint:c];
    
    UIBezierPath* circle1 = [UIBezierPath bezierPathWithArcCenter:a radius:self.frame.size.height * .05 startAngle:0 endAngle:2*pi clockwise:YES];
    UIBezierPath* circle2 = [UIBezierPath bezierPathWithArcCenter:b radius:self.frame.size.height * .05 startAngle:0 endAngle:2*pi clockwise:YES];
    UIBezierPath* circle3 = [UIBezierPath bezierPathWithArcCenter:c radius:self.frame.size.height * .05 startAngle:0 endAngle:2*pi clockwise:YES];
    
    UIBezierPath* arcPath = [self getArcForPoints:a b:b c:c andAngle:[self calculateAngleForPoints:a b:b c:c]];
    
    brushPattern = color;
    anglePath.LineWidth = 2;
    [brushPattern setStroke];
    [anglePath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    
    UIColor *fillColor = color;
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
    
    return anglePath;

}

- (UIBezierPath*)getArcForPoints:(CGPoint)a b:(CGPoint)b c:(CGPoint)c andAngle:(CGFloat)angle
{
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
    
  return [UIBezierPath bezierPathWithArcCenter:b radius:75
                                             startAngle:startAngle
                                               endAngle:endAngle
                                              clockwise:clockwise];
}

- (void) clearAngle
{
    [kneePath removeAllPoints];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if(drawKneePath)
    {
        kneeAngle = [self calculateAngleForPoints:[[kneeVertices objectAtIndex:0] CGPointValue]
                                                b:[[kneeVertices objectAtIndex:1] CGPointValue]
                                                c:[[kneeVertices objectAtIndex:2] CGPointValue]];
        kneePath = [self drawAngleWithPoints:[[kneeVertices objectAtIndex:0] CGPointValue]
                            b:[[kneeVertices objectAtIndex:1] CGPointValue]
                            c:[[kneeVertices objectAtIndex:2] CGPointValue]
                            andColor:[UIColor greenColor]];
    }
    if(drawShoulderPath)
    {
        shoulderAngle = [self calculateAngleForPoints:[[shoulderVertices objectAtIndex:0] CGPointValue]
                                                b:[[shoulderVertices objectAtIndex:1] CGPointValue]
                                                c:[[shoulderVertices objectAtIndex:2] CGPointValue]];
        shoulderPath = [self drawAngleWithPoints:[[shoulderVertices objectAtIndex:0] CGPointValue]
                                           b:[[shoulderVertices objectAtIndex:1] CGPointValue]
                                           c:[[shoulderVertices objectAtIndex:2] CGPointValue]
                                    andColor:[UIColor orangeColor]];
    }
    
    if(drawHipPath)
    {
        hipAngle = [self calculateAngleForPoints:[[hipVertices objectAtIndex:0] CGPointValue]
                                                    b:[[hipVertices objectAtIndex:1] CGPointValue]
                                                    c:[[hipVertices objectAtIndex:2] CGPointValue]];
        shoulderPath = [self drawAngleWithPoints:[[hipVertices objectAtIndex:0] CGPointValue]
                                               b:[[hipVertices objectAtIndex:1] CGPointValue]
                                               c:[[hipVertices objectAtIndex:2] CGPointValue]
                                        andColor:[UIColor purpleColor]];
    }
    
}

@end
