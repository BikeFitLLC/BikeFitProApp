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

#import "BikefitConstants.h"


@implementation AmazonClientManager

+(bool)verifyUserKey
{
    NSString *key = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTER_KEY_KEY];
    
    if(key != nil)
    {
        DynamoDBAttributeValue *fitterKey = [[DynamoDBAttributeValue alloc] initWithS:key];
        DynamoDBGetItemRequest *request = [[DynamoDBGetItemRequest alloc]initWithTableName:@"fitters"
                                                                                andKey:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                                        fitterKey, @"FitterKey",
                                                                                        nil]];
        request.consistentRead = YES;
    
        @try {
            [[AmazonClientManager ddb] setEndpoint: [AmazonEndpoints ddbEndpoint:US_WEST_2]];
            DynamoDBGetItemResponse *response = [[AmazonClientManager ddb] getItem:request];

            //if all was successful, update the last email property in case of crasehs
            [[NSUserDefaults standardUserDefaults]
                        setObject:[[[response item] objectForKey:@"Email"] s]
                        forKey:USER_DEFAULTS_USERNAME_KEY
                    ];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return true;
        }
        @catch (AmazonServiceException *exception) {
            NSLog(@"Error Retrieving Fitter Email from Key: %@", [exception description]);
            return false;
        }
    }
    
    return false;

}

+ (AmazonDynamoDBClient *)ddb
{
    static dispatch_once_t once;
    static AmazonDynamoDBClient *ddb;
    dispatch_once(&once, ^{
        AmazonCredentials *creds = [[AmazonCredentials alloc] initWithAccessKey:AWS_ACCESS_KEY
                                       withSecretKey:AWS_SECRET_KEY];
        ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:creds];
    });
    return ddb;
}
                                  
+ (AmazonS3Client *)s3
    {
        static dispatch_once_t once;
        static AmazonS3Client *s3;
        dispatch_once(&once, ^{
            AmazonCredentials *creds = [[AmazonCredentials alloc] initWithAccessKey:AWS_ACCESS_KEY
                                                                      withSecretKey:AWS_SECRET_KEY];
            s3 = [[AmazonS3Client alloc] initWithCredentials:creds];
            [s3 setEndpoint:@"http://s3-us-west-2.amazonaws.com"];
        });
        return s3;
    }
@end
