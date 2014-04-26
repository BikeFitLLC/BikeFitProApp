//
//  FootBottomView.h
//  bikefit
//
//  Created by Alfonso Lopez on 12/16/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FootBottomView : UIView
{
    CGPoint lastTouchLocation;
    UIBezierPath *footBoxPath;
}
@property CGPoint lastTouchLocation;
@property UIBezierPath *footBoxPath;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
