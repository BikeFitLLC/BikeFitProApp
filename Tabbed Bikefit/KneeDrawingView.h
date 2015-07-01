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
    
    bool drawingEnabled;
    
}

@property UIBezierPath *path;
@property UIBezierPath *lazerPath;
@property CGPoint startPoint;
@property bool drawingEnabled;

- (void) moveLazer:(int)numPixels;
-(void) stopLazer;


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
