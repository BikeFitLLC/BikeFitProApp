//
//  AmazonClientManager.h
//  bikefit
//
//  Created by Alfonso Lopez on 4/25/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "LoginDelegate.h"
//#import "AWSRuntime.h"
#import "CredentialProvider.h"

@interface AmazonClientManager : NSObject
{
    
}

+(bool)verifyLoggedInActive;
+(bool)verifyLoggedIn;
+(void)loginWithEmail:(NSString*)email andPassword:(NSString *)password andDelegate:(id<LoginDelegate>)delegate;
+(void)loginWithAmazon:(UIViewController<LoginDelegate> *)delegate;
+(void)isAmazonAccount:(NSString *)email andDelegate:(id<LoginDelegate>)delegate;

+ (AWSDynamoDB *)ddb;
+ (AWSS3 *)s3;
+ (AWSS3TransferManager *)s3TransferManager;
+ (CredentialProvider *)credProvider;

@end
