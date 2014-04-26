//
//  NoteImageView.h
//  bikefit
//
//  Created by Alfonso Lopez on 2/19/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteImageView : UIView {
    UIBezierPath *overlyPath;
    UIImage *image;
}
@property UIBezierPath *overlayPath;
@property UIImage *image;

@end
