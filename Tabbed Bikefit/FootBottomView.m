//
//  FootBottomView.m
//  bikefit
//
//  Created by Alfonso Lopez on 12/16/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "FootBottomView.h"

@implementation FootBottomView
{
    UIBezierPath *touchHighlightPath;
}
@synthesize lastTouchLocation;
@synthesize footBoxPath;

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
    CGRect rectangle = CGRectMake(0.0,
                                  self.frame.size.height *.25,
                                  self.frame.size.width,
                                  self.frame.size.height * .12);
    footBoxPath = [UIBezierPath bezierPathWithRect:rectangle];
    [footBoxPath setLineWidth:3.0];
    [footBoxPath setLineJoinStyle:kCGLineJoinBevel];
    [footBoxPath stroke];
    
    if(touchHighlightPath)
    {
        [touchHighlightPath setLineWidth:3.0];
        [touchHighlightPath setLineJoinStyle:kCGLineJoinBevel];
        [touchHighlightPath stroke];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    CGPoint touchLocation = [mytouch locationInView:self];

    [self setLastTouchLocation:touchLocation];
    CGFloat boxSize = 50;
    
    CGRect rect = CGRectMake(touchLocation.x - boxSize/2, touchLocation.y - boxSize/2, boxSize, boxSize);
    touchHighlightPath = [UIBezierPath bezierPathWithRect:rect];
    [self setNeedsDisplay];
    return;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
