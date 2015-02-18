//
//  AmazonClientManager.h
//  bikefit
//
//  Created by Alfonso Lopez on 4/25/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import "S3.h"
#import "DynamoDB.h"
//#import "AWSRuntime.h"
#import "CredentialProvider.h"

@interface AmazonClientManager : NSObject
{
    
}

+(bool)verifyUserKey;

+ (AWSDynamoDB *)ddb;
+ (AWSS3 *)s3;
+ (AWSS3TransferManager *)s3TransferManager;
+ (CredentialProvider *)credProvider;

@end
