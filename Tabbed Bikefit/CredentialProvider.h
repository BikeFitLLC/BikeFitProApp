//
//  CredentialProvider.h
//  bikefit
//
//  Created by Alfonso Lopez on 5/5/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSCore.h"
#import "AWSCredentialsProvider.h"
//#import <AWSRuntime/AWSRuntime.h>
#import <LoginWithAmazon/LoginWithAmazon.h>
@class AWSTask;

@interface CredentialProvider : NSObject <AWSCredentialsProvider,AIAuthenticationDelegate>
{
    NSDate *tokenExpiration;
    NSString *amznTokenString;
    NSTimer *timer;
    bool isLoggingIn;
}

@property bool isLoggingIn;
@property (nonatomic, readonly) NSString *accessKey;
@property (nonatomic, readonly) NSString *secretKey;
@property (nonatomic, readonly) NSString *sessionKey;

+ (instancetype)credentialsWithAccessKey:(NSString *)accessKey
                               secretKey:(NSString *)secretKey sessionKey:(NSString*)sessionKey;
- (instancetype)initWithAccessKey:(NSString *)accessKey
                        secretKey:(NSString *)secretKey sessionKey:(NSString*)sessionKey;


- (AWSTask *)refresh;
- (void) clear;

- (bool) isLoggedIn;

-(bool) isTokenValid;

- (void) createNewAccountWithEmail:(NSString *)email
                          password:(NSString *)password
                          shopName:(NSString *)shopName
                         firstName:(NSString *)firstName
                          lastName:(NSString *)lastName
                          callback:(void(^)(BOOL))callback;

@end
