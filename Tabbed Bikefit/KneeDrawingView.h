//
//  KneeDrawingVIew.h
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 9/28/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteImageView.h"
#import "DrawingView.h"

@interface KneeDrawingView : NoteImageView
{
    UIBezierPath *path;
    UIBezierPath *lazerPath;
    CGPoint startPoint;
    CGPoint endPoint;
    
    bool drawingEnabled;
    
}

@property UIBezierPath *path;
@property UIBezierPath *lazerPath;
@property CGPoint startPoint;
@property CGPoint endPoint;
@property bool drawingEnabled;

- (void)moveLazer:(int)numPixels;
- (void)stopLazer;

@end
