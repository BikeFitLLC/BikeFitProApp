//
//  KneeDrawingVIew.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 9/28/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "KneeDrawingVIew.h"
#import <CoreMotion/CoreMotion.h>



@implementation KneeDrawingView
{
    UIColor *brushPattern;
    NSOperationQueue *deviceQueue;
    CMMotionManager *motionManager;
    CGAffineTransform gravityTransform;
    CGFloat angle;
}
@synthesize path;
@synthesize lazerPath;
@synthesize startPoint;
@synthesize drawingEnabled;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        brushPattern = [UIColor blueColor];
        
        deviceQueue = [[NSOperationQueue alloc] init];
        motionManager = [[CMMotionManager alloc] init];
        
        startPoint.x = self.bounds.size.width /2;
        startPoint.y = 0;
        
        drawingEnabled = true;
        
        //////////Setup motion structures//////////////////
        
        CGFloat updateInterval = 1/600.0;
        CMAttitudeReferenceFrame frame = CMAttitudeReferenceFrameXArbitraryCorrectedZVertical;
        [motionManager setDeviceMotionUpdateInterval:updateInterval];
        [motionManager startDeviceMotionUpdatesUsingReferenceFrame:frame
                                                               toQueue:deviceQueue
                                                           withHandler:
         ^(CMDeviceMotion* motion, NSError* error){
             angle =  atan2( motion.gravity.x, motion.gravity.y );
         }];
        
        ////////timer for updating laser level
        [NSTimer scheduledTimerWithTimeInterval: 0.01 target: self
                                                          selector: @selector(updateLazer:)
                                                          userInfo: nil
                                                           repeats: YES];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //Setup the lazer line
    lazerPath = [[UIBezierPath alloc] init];
    lazerPath.LineWidth = 3;
    [lazerPath moveToPoint:startPoint];
    
    CGPoint newPoint;
    CGFloat laserLength = 1500.0;
    newPoint.x = (cosf(angle - 1.57079633) * laserLength) + startPoint.x;
    newPoint.y = sinf(angle - 1.57079633) * laserLength;
    [lazerPath addLineToPoint:newPoint];

    brushPattern = [UIColor redColor];
    [brushPattern setStroke];
    [lazerPath stroke];

    brushPattern = [UIColor blueColor];
    path.LineWidth = 10;
    [brushPattern setStroke];
    [path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    
}

-(void) stopLazer
{
    [motionManager stopDeviceMotionUpdates];
}

////////////////////////////////////
//Called every second to update the lazer level
/////////////////////////////////////
- (void) updateLazer:(NSTimer *) timer
{
    [self setNeedsDisplay];
}

/////////////////////////////////
//moves the starting point of the lazer line left
//////////////////////////////////
- (void) moveLazer:(int)numPixels
{
    startPoint.x  = startPoint.x + numPixels;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(drawingEnabled)
    {
        if(!path)
        {
            path = [[UIBezierPath alloc]init];
        }
        
        [path removeAllPoints];
        UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
        [path moveToPoint:[mytouch locationInView:self]];
    }
    return;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
   if(drawingEnabled)
   {
        UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
        [path addLineToPoint:[mytouch locationInView:self]];
        [self setNeedsDisplay];
   }
        return;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    return;
}
@end
