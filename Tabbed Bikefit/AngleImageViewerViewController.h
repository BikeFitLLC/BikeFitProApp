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
    IBOutlet UILabel *angleLabel;
    IBOutlet LegAngleImageView *drawingView;
    NSMutableArray * vertices;
}
@property NSMutableArray * vertices;
@end
