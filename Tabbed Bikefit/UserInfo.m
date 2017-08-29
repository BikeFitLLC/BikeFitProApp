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
@synthesize fitterid;
@synthesize transactionid;

+ (UserInfo*) userInfoWithEmail:(NSString*)email
                      firstName:(NSString*)firstname
                       lastName:(NSString*)lastName
                       password:(NSString*)password
                       shopName:(NSString*)shopName
                       fitterid:(NSString*)fitterid
                  transactionid:(NSString*)transactionid {
    
    return [[UserInfo alloc] initWithEmail:email
                                           firstName:firstname
                                            lastName:lastName
                                            password:password
                                            shopName:shopName
                                            fitterid:fitterid
                                         transactionid:transactionid];
    
}

- (id) initWithEmail:(NSString*)givenemail
                firstName:(NSString*)givenfirstname
                 lastName:(NSString*)givenlastName
                 password:(NSString*)givenpassword
                 shopName:(NSString*)givenshopName
            fitterid:(NSString*)givenfitterid
transactionid:(NSString*)giventransactionid{
    
    email = [givenemail copy];
    firstname = [givenfirstname copy];
    lastName  = [givenlastName copy];
    password = [givenpassword copy];
    shopName = [givenshopName copy];
    fitterid = [givenfitterid copy];
    transactionid = [giventransactionid copy];
    
    return self;
}

- (NSDictionary*) getPropertyDictionary {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    if( self.firstname ) {
        //TODO: what? we don;t have first or last name in the db
        //dict[@"FitterName"] = self.firstname;
    }
    if( self.lastName ) {
        
    }
    if( self.email ) {
        dict[@"FitterName"] = self.shopName;
    }
    if( self.shopName ) {
        dict[@"FitterName"] = self.shopName;
    }
    if( self.password ) {
        dict[@"Password"] = self.password;
    }
    if( self.transactionid ) {
        dict[@"TransactionID"] = self.transactionid;
    }
    
    return dict;
}
@end
