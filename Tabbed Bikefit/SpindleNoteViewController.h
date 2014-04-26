//
//  SpindleNoteViewController.h
//  bikefit
//
//  Created by Alfonso Lopez on 2/26/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteViewController.h"
#import "SpindleView.h"

@interface SpindleNoteViewController : NoteViewController <UIGestureRecognizerDelegate>
{
    IBOutlet SpindleView *spindleView;
}

@end
