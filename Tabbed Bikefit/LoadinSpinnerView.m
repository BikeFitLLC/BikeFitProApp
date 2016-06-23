//
//  LoadinSpinnerView.m
//  bikefit
//
//  Created by Alfonso Lopez on 6/28/15.
//  Copyright (c) 2015 Alfonso Lopez. All rights reserved.
//

#import "LoadinSpinnerView.h"

@implementation LoadinSpinnerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = .8;
    }
    
     UIImageView *background = [[UIImageView alloc] initWithImage:[self addBackground]];
    [self addSubview:background];
    
    // This is the new stuff here ;)
    UIActivityIndicatorView *indicator =
    [[UIActivityIndicatorView alloc]
      initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    
    // Set the resizing mask so it's not stretched
    indicator.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin;
    
    // Place it in the middle of the view
    indicator.center = self.center;
    
    // Add it into the spinnerView
    [self addSubview:indicator];
    
    // Start it spinning! Don't miss this step
    [indicator startAnimating];
    return self;
};

- (UIImage *)addBackground{
    // Create an image context (think of this as a canvas for our masterpiece) the same size as the view
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 1);
    
    // Our gradient only has two locations - start and finish. More complex gradients might have more colours
    size_t num_locations = 2;
    
    // The location of the colors is at the start and end
    CGFloat locations[2] = { 0.0, 1.0 };
    
    // These are the colors! That's two RBGA values
    CGFloat components[8] = {
        0.4,0.4,0.4, 0.8,
        0.1,0.1,0.1, 0.5 };
    
    // Create a color space
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
    
    // Create a gradient with the values we've set up
    CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
    
    // Set the radius to a nice size, 80% of the width. You can adjust this
    float myRadius = (self.bounds.size.width*.8)/2;
    
    // Now we draw the gradient into the context. Think painting onto the canvas
    CGContextDrawRadialGradient (UIGraphicsGetCurrentContext(), myGradient, self.center, 0, self.center, myRadius, kCGGradientDrawsAfterEndLocation);
    
    // Rip the 'canvas' into a UIImage object
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // And release memory
    CGColorSpaceRelease(myColorspace);
    CGGradientRelease(myGradient);
    UIGraphicsEndImageContext();
    
    // … obvious.
    return image;
}


@end
