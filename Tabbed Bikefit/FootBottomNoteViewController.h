//
//  FootBottomNoteViewController.h
//  bikefit
//
//  Created by Alfonso Lopez on 12/16/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FootBottomNote.h"
#import "FootBottomView.h"
#import "NoteViewController.h"

@interface FootBottomNoteViewController : NoteViewController
{
    IBOutlet FootBottomView *footBottomView;
    IBOutlet UIImageView *leftFootImage;
    IBOutlet UIImageView *rightFootImage;
    
}

- (IBAction) saveLocation:(id)sender;
@end
