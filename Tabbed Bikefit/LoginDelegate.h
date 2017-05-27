//
//  LoginDelegate.h
//  bikefit
//
//  Created by Alfonso Lopez on 11/6/15.
//  Copyright © 2015 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoginDelegate<NSObject>

- (void)onUserSignedIn;

@optional
- (void)amazonCheckResult:(BOOL)isAmazonAccount accountExists:(BOOL)exists;

@end
