//
//  Util.h
//  bikefit
//
//  Created by Max on 2/15/17.
//  Copyright © 2017 Alfonso Lopez. All rights reserved.
//

@interface Util : NSObject

+ (NSString*)getLocalizedString:(NSString*)key;
+ (void)setScreenLeftRightTitle:(UIViewController*)viewController leftSelected:(BOOL)leftSelected key:(NSString*)key;
+ (void)setTitle:(UIViewController*)viewController title:(NSString*)text;

@end
