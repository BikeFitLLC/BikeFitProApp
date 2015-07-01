//
//  VarusViewerViewController.h
//  bikefit
//
//  Created by Alfonso Lopez on 7/7/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "ImageViewerViewController.h"
#import "DrawingView.h"

@interface VarusViewerViewController : ImageViewerViewController
{
    DrawingView *drawingView;
    CGFloat varusAngle;
    IBOutlet UILabel *angleLabel;
}

@property CGFloat varusAngle;

@end
