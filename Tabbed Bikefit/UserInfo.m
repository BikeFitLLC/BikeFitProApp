//
//  UserInfo.m
//  bikefit
//
//  Created by Alfonso Lopez on 6/4/17.
//  Copyright © 2017 Alfonso Lopez. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
@synthesize email;
@synthesize firstname;
@synthesize lastName;
@synthesize password;
@synthesize shopName;


+ (UserInfo*) userInfoWithEmail:(NSString*)email
                      firstName:(NSString*)firstname
                       lastName:(NSString*)lastName
                       password:(NSString*)password
                       shopName:(NSString*)shopName {
    
    return [[UserInfo alloc] initWithEmail:email
                                           firstName:firstname
                                            lastName:lastName
                                            password:password
                                            shopName:shopName];
    
}

- (id) initWithEmail:(NSString*)givenemail
                firstName:(NSString*)givenfirstname
                 lastName:(NSString*)givenlastName
                 password:(NSString*)givenpassword
                 shopName:(NSString*)givenshopName {
    
    email = [givenemail copy];
    firstname = [givenfirstname copy];
    lastName  = [givenlastName copy];
    password = [givenpassword copy];
    shopName = [givenshopName copy];
    
    return self;
}
@end
