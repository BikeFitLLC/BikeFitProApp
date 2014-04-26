//
//  NoteImageView.m
//  bikefit
//
//  Created by Alfonso Lopez on 2/19/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "NoteImageView.h"

@implementation NoteImageView
{
    UIColor *brushPattern;
}
@synthesize overlayPath;
@synthesize image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if(image)
    {
        //[self setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        //CGRect f = self.frame;
        [image drawInRect:self.frame];

    }
    
    brushPattern = [UIColor yellowColor];
    [brushPattern setStroke];
    overlayPath.lineWidth = 5;
    [overlayPath stroke];
}

@end
