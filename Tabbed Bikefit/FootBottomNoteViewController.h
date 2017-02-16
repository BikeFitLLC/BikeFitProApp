//
//  FootBottomNoteViewController.h
//  bikefit
//
//  Created by Alfonso Lopez on 12/16/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "FootBottomNote.h"
#import "FootBottomView.h"
#import "NoteViewController.h"

#import <UIKit/UIKit.h>

@interface FootBottomNoteViewController : NoteViewController
{
    IBOutlet UITextView *textView;
}

- (IBAction) saveLocation:(id)sender;

@end
