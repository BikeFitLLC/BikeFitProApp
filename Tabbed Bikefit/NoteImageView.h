//
//  NoteImageView.h
//  bikefit
//
//  Created by Alfonso Lopez on 2/19/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingView.h"

@interface NoteImageView : UIView {
    UIBezierPath *overlayPath;
    UIImageView *imageView;
}

@property UIImageView *imageView;
@property UIBezierPath *overlayPath;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)imageToShow;

@end
