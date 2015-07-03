//
//  ImageViewerViewController.h
//  bikefit
//
//  Created by Alfonso Lopez on 3/27/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoniometerViewController.h"
#import "DrawingView.h";

@interface ImageViewerViewController : UIViewController
{
    IBOutlet UIImageView *imageView;
    DrawingView *drawingView;
    
    UIImage *image;
    UIBezierPath *overlayPath;
    
}
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIBezierPath *overlayPath;

@end
