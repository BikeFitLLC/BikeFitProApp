//
//  CredentialProvider.m
//  bikefit
//
//  Created by Alfonso Lopez on 5/5/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "CredentialProvider.h"
#import "BikefitConstants.h"

#import <LoginWithAmazon/LoginWithAmazon.h>

@implementation CredentialProvider
@synthesize isLoggingIn;

-(id)init
{
    timer = [NSTimer scheduledTimerWithTimeInterval:600
                                            target:self
                                            selector:@selector(checkTokenExpirationAndRefresh)
                                            userInfo:nil
                                            repeats:YES];
    return self;
}

+ (instancetype)credentialsWithAccessKey:(NSString *)accessKey
                               secretKey:(NSString *)secretKey sessionKey:(NSString*)sessionKey
{
    CredentialProvider *credentials = [[CredentialProvider alloc]initWithAccessKey:accessKey secretKey:secretKey sessionKey:sessionKey];
    return credentials;
    
}

- (instancetype)initWithAccessKey:(NSString *)accessKey
                        secretKey:(NSString *)secretKey sessionKey:(NSString*)sessionKey
{
    if (self = [super init]) {
        _accessKey = accessKey;
        _secretKey = secretKey;
        _sessionKey = sessionKey;
    }
    return self;
}

- (BFTask *)refresh
{
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_USERNAME_KEY];
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTERNAME_KEY];
    
    if( email == nil)
    {
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:[NSString stringWithFormat:@"User Not Logged In. Use the Settings page to login"]
                                   delegate:nil
                          cancelButtonTitle:@"OK"otherButtonTitles:nil
          ] show];
        return nil;
    }
    
    //Setup the URl to the token vending machine
    NSString *urlstring = [NSString stringWithFormat:TOKEN_VENDING_MACHINE_URL_FORMAT, email, name, amznTokenString];
    NSURL *tvmUrl = [NSURL URLWithString:[urlstring stringByAddingPercentEscapesUsingEncoding : NSUTF8StringEncoding]];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:tvmUrl];
    NSURLResponse *response;
    NSError *error;
    
    //Get token information from the token vending machine
    NSData *tvmData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error)
    {
        NSLog(@"Error getting credentials from TVM. %@", [error description]);
        //creds = [[AmazonCredentials alloc] init];
        return nil;
    }
    
    //Extract our new credentials
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:tvmData options:NSJSONReadingMutableContainers error:&error];
    
    NSString *errorMessage =  [json objectForKey:@"error"];
    if(errorMessage)
    {
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:USER_DEFAULTS_ACCOUNT_ACTIVE_KEY];
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:[NSString stringWithFormat:@"User authorization failed with message: %@",errorMessage]
                                   delegate:nil
                          cancelButtonTitle:@"OK"otherButtonTitles:nil
          ] show];
        
        return nil;
    }
    
    if(error)
    {
        NSLog(@"Error getting credentials from TVM: %@", [error description]);
        //creds = [[AmazonCredentials alloc] init];
        return nil;
    }
    
    //if there is a current fit file open, check to make sure it has an id
    NSString *fitid = [AthletePropertyModel getProperty:AWS_FIT_ATTRIBUTE_FITID];
    if([fitid isEqualToString: LOCAL_FILE_ID])
    {
        NSString *newFitID = [[NSUUID UUID] UUIDString];
        [AthletePropertyModel setProperty:AWS_FIT_ATTRIBUTE_FITID value:newFitID];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:USER_DEFAULTS_ACCOUNT_ACTIVE_KEY];
    [[NSUserDefaults standardUserDefaults] setBool:[[json objectForKey:@"trial"] boolValue] forKey:USER_DEFAULTS_IS_TRIAL_ACCOUNT];
    
    
    _accessKey = [json objectForKey:@"accesskey"];
    _secretKey = [json objectForKey:@"secretkey"];
    _sessionKey = [json objectForKey:@"token"];

    /*
    creds = [[AmazonCredentials alloc]
             initWithAccessKey:[json objectForKey:@"accesskey"]
             withSecretKey:[json objectForKey:@"secretkey"]
             withSecurityToken:[json objectForKey:@"token"]];
    */
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSString *date = [json objectForKey:@"expiration"];
    tokenExpiration = [dateFormatter dateFromString:date];
    
    
    //Now we have a good response from the TVM.  Populate credentials and Fitterid
    [[NSUserDefaults standardUserDefaults] setObject:[json objectForKey:@"fitterid"] forKey:USER_DEFAULTS_FITTERID_KEY];
    
    return nil;
}

- (bool) isLoggedIn
{
    return _accessKey != nil;
}

//////////////////////////////////////
//Returns true if the credential token is not expired
//false otherwise
///////////////////////////////////////
-(bool) isTokenValid
{
    if(!tokenExpiration)
    {
        return false;
    }
    
    NSDate *now = [NSDate date];
    return [tokenExpiration compare:now] != NSOrderedAscending;
}

- (void) checkTokenExpirationAndRefresh
{
    NSDate *now = [NSDate date];
    int interval = [now timeIntervalSinceDate:tokenExpiration];
    
    if(abs(interval)/60 < 10)
    {
        //if the token expires in fewer than 10 minutes, refresh it.
        [AIMobileLib getAccessTokenForScopes:[NSArray arrayWithObject:@"profile"]
                                                withOverrideParams:nil
                                                delegate:self];
    }
}

- (void) clear
{
    _accessKey = nil;
    _secretKey = nil;
    _sessionKey = nil;
}

#pragma mark Implementation of getAccessTokenForScopes:withOverrideParams:delegate: delegates.
- (void)requestDidSucceed:(APIResult *)apiResult
{
    amznTokenString = [apiResult result];
    [self refresh];
    isLoggingIn = false;
    
    return;
}

- (void)requestDidFail:(APIError *)errorResponse {
    isLoggingIn = false;
    // If error code = kAIApplicationNotAuthorized, allow user to log in again.
    if(errorResponse.error.code == kAIApplicationNotAuthorized)
    {
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:[NSString stringWithFormat:@"User Not Logged In. Use the Settings page to login"]
                                   delegate:nil
                          cancelButtonTitle:@"OK"otherButtonTitles:nil
          ] show];
    }
    else {
        // Handle other errors
        [AthletePropertyModel setOfflineMode:true];
        [[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Error occured with message: %@ - Entering Offline Mode", errorResponse.error.message] delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil]show];
    }
}

@end
