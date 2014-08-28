//
//  VarusDrawingView.h
//  bikefit
//
//  Created by Alfonso Lopez on 2/24/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteImageView.h"

@interface VarusDrawingView : NoteImageView
{
    CGPoint endPointLocation;
    CGPoint startPointLocation;
    CGFloat barYPosition;
}

@property CGPoint endPointLocation;
@property CGPoint startPointLocation;
@property CGFloat barYPosition;


@end
