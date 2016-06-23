//
//  VarusNoteViewController.h
//  bikefit
//
//  Created by Alfonso Lopez on 2/24/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoNoteViewController.h"
#import "VarusDrawingView.h"

@interface VarusNoteViewController : VideoNoteViewController <UIGestureRecognizerDelegate>
{
    IBOutlet UILabel *angleLabel;
    IBOutlet UIImageView *leftLegImageView;
    IBOutlet UIImageView *rightLegImageView;
    IBOutlet UIImageView *ffmdImageView;
    UIImageView *upDownImageView;
    UIImageView *rotateArrowsImageView;

}

@end
