//
//  HomeViewButton.m
//  bikefit
//
//  Created by Johnny5 on 9/6/16.
//  Copyright © 2016 Alfonso Lopez. All rights reserved.
//

#import "HomeViewButton.h"

@interface HomeViewButton()
{
    UIButton *backingButton;
    UILabel *titleLabel;
    UIImageView *imageView;
    UIView *detailView;
}

@end

@implementation HomeViewButton

- (instancetype)initWithFrame:(CGRect)frame target:(id)target selector:(SEL)selector title:(NSString *)title image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addImage:image title:title];
        [self addBackingButton:target selector:selector];
    }
    
    return self;
}

- (void)addBackingButton:(id)target selector:(SEL)selector {
    if (!backingButton) {
        backingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backingButton.frame = self.bounds;
        backingButton.backgroundColor = [UIColor clearColor];
        [self addSubview:backingButton];
        [backingButton addTarget:self action:@selector(tintViews) forControlEvents:UIControlEventTouchDown];
        [backingButton addTarget:self action:@selector(untintViews) forControlEvents:UIControlEventTouchUpInside];
        [backingButton addTarget:self action:@selector(untintViews) forControlEvents:UIControlEventTouchUpOutside];

    }
    [backingButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)addImage:(UIImage *)image title:(NSString *)title
{
    CGFloat imageViewEdge = CGRectGetWidth(self.bounds) * 0.33;
    CGFloat spacing = imageViewEdge * 0.33;
    CGFloat labelHeight = imageViewEdge * 0.25;
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds) - (imageViewEdge * 0.5),
                                                                  0,
                                                                  imageViewEdge,
                                                                  imageViewEdge)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    imageView.image = image;
    
    if (!titleLabel) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                               CGRectGetMaxY(imageView.frame) + spacing,
                                                               CGRectGetWidth(self.bounds),
                                                               labelHeight)];
        titleLabel.font = [UIFont fontWithName:@"Gill Sans" size:labelHeight];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    if (!detailView) {
        detailView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                              0,
                                                              CGRectGetWidth(self.bounds),
                                                              CGRectGetMaxY(titleLabel.frame))];
        detailView.backgroundColor = [UIColor clearColor];
        [detailView addSubview:imageView];
        [detailView addSubview:titleLabel];
        [self addSubview:detailView];
    }
    
    titleLabel.text = title;
    
    //adjust view
    detailView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)enable:(BOOL)enable
{
    backingButton.enabled = enable;
    if (enable) {
        [self untintViews];
    } else {
        [self tintViews];
    }
}

- (void)tintViews {
    imageView.alpha = 0.5;
    titleLabel.alpha = 0.5;
}

- (void)untintViews {
    imageView.alpha = 1;
    titleLabel.alpha = 1;
}

@end
