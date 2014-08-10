//
//  VarusViewerViewController.h
//  bikefit
//
//  Created by Alfonso Lopez on 7/7/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "ImageViewerViewController.h"

@interface VarusViewerViewController : ImageViewerViewController
{
    CGFloat varusAngle;
    IBOutlet UILabel *angleLable;
}

@property CGFloat varusAngle;

@end
