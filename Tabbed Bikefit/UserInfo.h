//
//  UserInfo.h
//  bikefit
//
//  Created by Alfonso Lopez on 6/4/17.
//  Copyright © 2017 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (readonly) NSString* email;
@property (readonly) NSString* firstname;
@property (readonly) NSString* lastName;
@property (readonly) NSString* password;
@property (readonly) NSString* shopName;

+ (UserInfo*) userInfoWithEmail:(NSString*)email
                      firstName:(NSString*)firstname
                       lastName:(NSString*)lastName
                       password:(NSString*)password
                       shopName:(NSString*)shopName;
@end
