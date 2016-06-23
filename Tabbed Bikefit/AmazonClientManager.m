    //
//  AmazonClientManager.m
//  bikefit
//
//  Created by Alfonso Lopez on 4/25/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "AmazonClientManager.h"
#import "AMZNAuthorizeUserDelegate.h"
#import "AWSS3.h"
#import "AWSDynamoDB.h"

#import "CredentialProvider.h"
#import "LoginDelegate.h"
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

+(void)loginWithEmail:(NSString*)email andPassword:(NSString *)password andDelegate:(id<LoginDelegate>)delegate
{
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:USER_DEFAULTS_PASSWORD_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:USER_DEFAULTS_USERNAME_KEY];
    
    [[AmazonClientManager credProvider] refresh];
    [delegate onUserSignedIn];
    return;
}

+(void)loginWithAmazon:(UIViewController<LoginDelegate> *)delegate
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_PASSWORD_KEY];
    
    // Make authorize call to SDK to get authorization from the user.
    // Requesting 'profile' scopes for the current user.
    [[AmazonClientManager credProvider] setIsLoggingIn:true];
    NSArray *requestScopes = [NSArray arrayWithObject:@"profile"];
    AMZNAuthorizeUserDelegate* authDelegate = [[AMZNAuthorizeUserDelegate alloc] initWithParentController:delegate];
    
    [AIMobileLib authorizeUserForScopes:requestScopes delegate:authDelegate];

    
}
+(void)isAmazonAccount:(NSString *)email andDelegate:(id<LoginDelegate>)delegate;
{
    NSString *urlQueryString = [NSString stringWithFormat:TVM_IS_AMAZON_PATH, email];
    NSURL *tvmUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", TVM_HOSTNAME, urlQueryString]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:tvmUrl
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                       {
                                        dispatch_sync(dispatch_get_main_queue(), ^
                                        {
                                            if(error)
                                            {
                                                NSLog(@"Error Contacting TVM to create account %@", [error description]);
                                                return;
                                            }
                                            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                            NSString* isAmazonAccount = [json objectForKey:@"isAmazonAccount"];
                                            NSString* exists = [json objectForKey:@"exists"];
                                            [delegate amazonCheckResult:[isAmazonAccount boolValue] accountExists:[exists boolValue]];
                                            });
                                       }];
    
    [dataTask resume];

    
}
@end
