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
    
    if(key != nil && [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_ONLINEMODE_KEY])
    {
        [[AmazonClientManager ddb] setEndpoint:[AmazonEndpoints ddbEndpoint:US_WEST_2]];
        [[AmazonClientManager s3] setEndpoint:[AmazonEndpoints s3Endpoint:US_WEST_2]];
        
        DynamoDBAttributeValue *fitterKey = [[DynamoDBAttributeValue alloc] initWithS:key];
        DynamoDBGetItemRequest *request = [[DynamoDBGetItemRequest alloc]initWithTableName:@"fitters"
                                                                                andKey:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                                        fitterKey, USER_DEFAULTS_FITTER_KEY_KEY,
                                                                                        nil]];
        request.consistentRead = YES;
    
        @try {
            DynamoDBGetItemResponse *response = [[AmazonClientManager ddb] getItem:request];
            
            //TODO: add a field called "active" to the database. THen here check
            //for it to be true.
            //if all was successful, update the last email property in case of crasehs
            /*
            [[NSUserDefaults standardUserDefaults]
                        setObject:[[[response item] objectForKey:AWS_FIT_ATTRIBUTE_FITID] s]
                        forKey:USER_DEFAULTS_FITID_KEY
                    ];
            [[NSUserDefaults standardUserDefaults] synchronize];
             */
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
        });
        return s3;
    }
@end
