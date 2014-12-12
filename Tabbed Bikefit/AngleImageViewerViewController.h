//
//  AngleImageViewerViewController.h
//  bikefit
//
//  Created by Alfonso Lopez on 4/2/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "ImageViewerViewController.h"
#import "LegAngleImageView.h"

@interface AngleImageViewerViewController : ImageViewerViewController
{
    UILabel *kneeAngleLabel;
    UILabel *shoulderAngleLabel;
    UILabel *hipAngleLabel;
    
    IBOutlet LegAngleImageView *drawingView;
}
@property NSMutableArray *kneeVertices;
@property NSMutableArray *shoulderVertices;
@property NSMutableArray *hipVertices;

@property CGFloat kneeAngle;
@property CGFloat shoulderAngle;
@property CGFloat hipAngle;
@end
