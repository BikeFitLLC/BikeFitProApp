//
//  KneeViewController.h
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 9/28/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<AVFoundation/AVFoundation.h>
#import "KneeDrawingView.h"
#import "KneeViewNote.h"
#import "VideoNoteViewController.h"

@interface KneeViewController : VideoNoteViewController <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    
    IBOutlet UIButton *lazerLeftButton;
    IBOutlet UIButton *lazerRightButton;

}

- (IBAction)moveLazerLeft:(id)sender;
- (IBAction)moveLazerRight:(id)sender;

- (IBAction)keepLine:(id)sender;

- (void) stopCapturing;



@end
