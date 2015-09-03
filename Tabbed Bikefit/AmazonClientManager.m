    //
//  AmazonClientManager.m
//  bikefit
//
//  Created by Alfonso Lopez on 4/25/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "AmazonClientManager.h"
//#import <AWSRuntime/AWSRuntime.h>
#import "AWSS3.h"
#import "AWSDynamoDB.h"

#import "CredentialProvider.h"

#import "BikefitConstants.h"


@implementation AmazonClientManager


/*
 Checks if credentials are good, if they are not attempts to refresh them and returns true
 Otherwise returns false
 
 it is safe to make AWS calls if this method returns true
 */
+(bool)verifyLoggedIn
{
    bool isAWSActive = true;
    isAWSActive = isAWSActive && [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_USERNAME_KEY] !=nil;
    isAWSActive = isAWSActive && [[AmazonClientManager credProvider] isTokenValid];
    
    return isAWSActive;
}
  
    
+(bool)verifyLoggedInActive
{
    bool isAWSActive = true;
    isAWSActive = isAWSActive && [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_USERNAME_KEY] !=nil;
    isAWSActive = isAWSActive && [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_ACCOUNT_ACTIVE_KEY];
    isAWSActive = isAWSActive && [[AmazonClientManager credProvider] isTokenValid];

    return isAWSActive;
}

+ (CredentialProvider *)credProvider
{
    static dispatch_once_t once;
    static CredentialProvider *provider;
    
    dispatch_once(&once, ^{
        provider = [[CredentialProvider alloc] init];
    });
    return provider;
}

+ (AWSDynamoDB *)ddb
{
    static dispatch_once_t once;
    static AWSDynamoDB *ddb;
    
    dispatch_once(&once, ^{
        ddb = [AWSDynamoDB defaultDynamoDB];
        //[ddb setEndpoint:AMAZON_DDB_US_WEST_2_ENDPOINT];
    });
    return ddb;
};
                                  
+ (AWSS3 *)s3
    {
        static dispatch_once_t once;
        static AWSS3 *s3;
        dispatch_once(&once, ^{
            s3 = [AWSS3 defaultS3];
            //[s3 setEndpoint:AMAZON_S3_US_WEST_2_ENDPOINT];
        });
        return s3;
    }

+ (AWSS3TransferManager *)s3TransferManager
{
    static dispatch_once_t once;
    static AWSS3TransferManager *s3TransferManager;
    dispatch_once(&once, ^{
        s3TransferManager = [AWSS3TransferManager defaultS3TransferManager];
        //s3TransferManager.s3 = [AmazonClientManager s3];
    });
    return s3TransferManager;
}
@end
