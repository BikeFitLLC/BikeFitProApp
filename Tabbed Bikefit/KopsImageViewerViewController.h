//
//  KopsImageViewerViewController.h
//  bikefit
//
//  Created by Alfonso Lopez on 4/2/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KopsViewController.h"

@interface KopsImageViewerViewController : KopsViewController
{
    UIImage *image;
    IBOutlet UIImageView *imageView;
}

@property (nonatomic, retain) UIImage *image;
@end
