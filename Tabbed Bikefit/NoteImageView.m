//
//  NoteImageView.m
//  bikefit
//
//  Created by Alfonso Lopez on 2/19/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "NoteImageView.h"

@implementation NoteImageView

@synthesize imageView;
@synthesize overlayPath;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)imageToShow
{
    self = [super initWithFrame:frame];
    if (self) {
        imageView  = [[UIImageView alloc] initWithImage:imageToShow];
        imageView.center = self.center;
        [self addSubview:imageView];


    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
}
*/
@end
