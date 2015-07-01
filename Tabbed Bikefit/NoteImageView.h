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
    UIBezierPath *overlyPath;
    UIImageView *imageView;
}

@property UIImageView *imageView;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)imageToShow;

@end
