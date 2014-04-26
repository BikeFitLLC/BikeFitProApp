//
//  SpindleView.h
//  bikefit
//
//  Created by Alfonso Lopez on 2/26/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpindleView : UIView
{
    CGFloat spindleYPosition;
    UIBezierPath *boxPath;
}

@property UIBezierPath *boxPath;
@property CGFloat spindleYPosition;
@end
