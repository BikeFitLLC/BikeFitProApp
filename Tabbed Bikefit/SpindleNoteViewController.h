//
//  SpindleNoteViewController.h
//  bikefit
//
//  Created by Alfonso Lopez on 2/26/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "NoteViewController.h"
#import "SpindleView.h"

#import <UIKit/UIKit.h>

@interface SpindleNoteViewController : NoteViewController <UIGestureRecognizerDelegate>
{
    IBOutlet SpindleView *spindleView;
    
    IBOutlet UIImageView *leftFootGraphic;
    IBOutlet UIImageView *rightFootGraphic;
    IBOutlet UIImageView *leftFootTextImageView;
    IBOutlet UIImageView *rightFootTextImageView;
    IBOutlet UIImageView *spindleImageView;
}

@end
