//
//  LegAngleViewController.h
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 10/1/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#import "AngleNote.h"
#import "VideoNoteViewController.h"

@interface AngleFinderViewController : VideoNoteViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>{
    
    IBOutlet UILabel *angleLabel;
    IBOutlet UIScrollView *previewScroll;
    
    
    NSString *labelText;
    UIImageView *leftArrowImageView;
    UIImageView *rightArrowImageView;
    
    
    NSString *propertyName;
}

@property NSString *propertyName;
@property NSString *labelText;
//@property NSMutableArray * vertices;
@property float angle;

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
- (void)setVertices:(NSMutableArray *)vertices;
@end
