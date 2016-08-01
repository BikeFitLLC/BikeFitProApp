//
//  GUIKneeTouchInterceptorView.m
//  bikefit
//
//  Created by Developer on 8/1/16.
//

#import "GUIKneeTouchInterceptorView.h"

@implementation GUIKneeTouchInterceptorView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.delegate) {
        [self.delegate kneeViewTouchesBegan:touches];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.delegate) {
        [self.delegate kneeViewTouchesMoved:touches];
    }

}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.delegate) {
        [self.delegate kneeViewTouchesEnded:touches];
    }

}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.delegate) {
        [self.delegate kneeViewTouchesEnded:touches];
    }

}

@end
