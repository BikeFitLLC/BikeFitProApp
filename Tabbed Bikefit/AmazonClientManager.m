    //
//  AmazonClientManager.m
//  bikefit
//
//  Created by Alfonso Lopez on 4/25/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "AmazonClientManager.h"
#import <AWSRuntime/AWSRuntime.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

#import "CredentialProvider.h"

#import "BikefitConstants.h"


@implementation AmazonClientManager

+(bool)verifyUserKey
{
    bool isAWSActive = true;
    isAWSActive = isAWSActive && [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTER_KEY_KEY] !=nil;
    isAWSActive = isAWSActive && [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_ONLINEMODE_KEY];
    //isAWSActive = isAWSActive &&
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

+ (AmazonDynamoDBClient *)ddb
{
    static dispatch_once_t once;
    static AmazonDynamoDBClient *ddb;
    
    dispatch_once(&once, ^{
        ddb = [[AmazonDynamoDBClient alloc] initWithCredentialsProvider:[AmazonClientManager credProvider]];
        [ddb setEndpoint:AMAZON_DDB_US_WEST_2_ENDPOINT];
    });
    return ddb;
};
                                  
+ (AmazonS3Client *)s3
    {
        static dispatch_once_t once;
        static AmazonS3Client *s3;
        dispatch_once(&once, ^{
            s3 = [[AmazonS3Client alloc] initWithCredentialsProvider:[AmazonClientManager credProvider]];
            [s3 setEndpoint:AMAZON_S3_US_WEST_2_ENDPOINT];
        });
        return s3;
    }
@end
