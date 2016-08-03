//
//  KneeDrawingVIew.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 9/28/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "KneeDrawingVIew.h"

@implementation KneeDrawingView
{
    UIColor *brushPattern;
}
@synthesize path;
@synthesize lazerPath;
@synthesize startPoint;
@synthesize endPoint;
@synthesize drawingEnabled;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        brushPattern = [UIColor blueColor];
        
        startPoint.x = self.bounds.size.width /2;
        startPoint.y = 0;
        
        drawingEnabled = true;
        
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
    lazerPath.lineWidth = 3;
    [lazerPath moveToPoint:startPoint];
    [lazerPath addLineToPoint:endPoint];

    brushPattern = [UIColor redColor];
    [brushPattern setStroke];
    [lazerPath stroke];

    brushPattern = [UIColor blueColor];
    path.lineWidth = 10;
    [brushPattern setStroke];
    [path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    
}

-(void) stopLazer
{
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

@end
