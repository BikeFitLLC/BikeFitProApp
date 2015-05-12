//
//  SaddleTiltView.m
//  bikefit
//
//  Created by Alfonso Lopez on 5/11/15.
//  Copyright (c) 2015 Alfonso Lopez. All rights reserved.
//

#import "SaddleTiltView.h"
#import <CoreMotion/CoreMotion.h>

@implementation SaddleTiltView
{
    NSOperationQueue *deviceQueue;
    CMMotionManager *motionManager;
}
@synthesize angle;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        

    }
    return self;
}

@end
