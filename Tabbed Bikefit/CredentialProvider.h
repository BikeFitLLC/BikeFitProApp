//
//  CredentialProvider.h
//  bikefit
//
//  Created by Alfonso Lopez on 5/5/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSRuntime/AWSRuntime.h>
#import <LoginWithAmazon/LoginWithAmazon.h>

@interface CredentialProvider : NSObject <AmazonCredentialsProvider,AIAuthenticationDelegate>
{
    AmazonCredentials *creds;
    NSDate *tokenExpiration;
    NSString *amznTokenString;
    NSTimer *timer;
    bool isLoggingIn;
}
@property bool isLoggingIn;

- (void) clear;

- (bool) isLoggedIn;

-(bool) isTokenValid;

@end
