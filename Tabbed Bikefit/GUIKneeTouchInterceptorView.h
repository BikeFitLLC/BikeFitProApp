//
//  GUIKneeTouchInterceptorView.h
//  bikefit
//
//  Created by Developer on 8/1/16.
//

#import <UIKit/UIKit.h>

@protocol GUIKneeTouchInterceptorViewDelegate <NSObject>

- (void)kneeViewTouchesBegan:(NSSet *)touches;
- (void)kneeViewTouchesMoved:(NSSet *)touches;
- (void)kneeViewTouchesEnded:(NSSet *)touches;

@end

@interface GUIKneeTouchInterceptorView : UIView

@property (nonatomic, assign) id <GUIKneeTouchInterceptorViewDelegate> delegate;

@end
