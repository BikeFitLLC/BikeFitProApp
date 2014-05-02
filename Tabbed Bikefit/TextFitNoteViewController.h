//
//  TextFitNoteViewController.h
//  bikefit
//
//  Created by Alfonso Lopez on 12/11/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FitNote.h"
#import "NoteViewController.h"

@interface TextFitNoteViewController : NoteViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
    
    IBOutlet UITextField *textField;
    IBOutlet UIPickerView *saddleNotePicker;
}

- (IBAction) addBtnPressed:(id)sender;
@end
