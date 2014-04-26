//
//  LegAngleImageView.h
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 10/3/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteImageView.h"

@interface LegAngleImageView : NoteImageView
{
    UIBezierPath *path;
    UIBezierPath *arcPath;
    
    NSMutableArray * vertices;
    
    float angle;
    bool clockwise;
    //int radius;
}

@property UIBezierPath *path;
@property UIBezierPath *arcPath;
@property NSMutableArray *vertices;
@property float angle;

- (void) drawAngle:(CGPoint)a b:(CGPoint)b c:(CGPoint)c;
- (void) clearAngle;
- (void) calculateAngle;
@end
