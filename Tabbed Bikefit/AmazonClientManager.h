//
//  AmazonClientManager.h
//  bikefit
//
//  Created by Alfonso Lopez on 4/25/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSRuntime/AWSRuntime.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface AmazonClientManager : NSObject
{
    
}

+(bool)verifyUserKey;

+ (AmazonDynamoDBClient *)ddb;
+ (AmazonS3Client *)s3;

@end
