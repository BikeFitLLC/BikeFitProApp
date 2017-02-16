//
//  UIColor+Util_m.m
//  bikefit
//
//  Created by Max on 2/15/17.
//  Copyright © 2017 Alfonso Lopez. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (NSString*)getLocalizedString:(NSString*)key {
    return [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key];
}

+ (void)setTitle:(UIViewController*)viewController title:(NSString*)text {
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor], NSForegroundColorAttributeName,
                                               nil];
    [viewController.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    viewController.title = text;
}

@end
