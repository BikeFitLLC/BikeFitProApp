//
//  HomeViewButton.h
//  bikefit
//
//  Created by Johnny5 on 9/6/16.
//  Copyright © 2016 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewButton : UIView

- (instancetype)initWithFrame:(CGRect)frame target:(id)target selector:(SEL)selector title:(NSString *)title image:(UIImage *)image;
- (void)enable:(BOOL)enable;

@end
