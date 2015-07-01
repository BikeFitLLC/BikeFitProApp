//
//  LegAngleImageView.h
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 10/3/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteImageView.h"

@interface GoniometerDrawingView : UIView
{
    bool clockwise;
    //int radius;
}

@property bool drawKneePath;
@property bool drawShoulderPath;
@property bool drawHipPath;

@property UIBezierPath *kneePath;
@property NSMutableArray *kneeVertices;

@property UIBezierPath *shoulderPath;
@property NSMutableArray *shoulderVertices;

@property UIBezierPath *hipPath;
@property NSMutableArray *hipVertices;

@property float kneeAngle;
@property float shoulderAngle;
@property float hipAngle;

- (void) clearAngle;
- (CGFloat) calculateAngleForPoints:(CGPoint)a b:(CGPoint)b c:(CGPoint)c;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)imageToShow;
@end
