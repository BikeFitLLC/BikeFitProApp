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
#import "AMZNLogoutDelegate.h"

const int AUTHENTICATED_TIMEOUT_MINUTES = 60 * 24; // 24 hours

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
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_PASSWORD_KEY];
    
    if( email == nil)
    {
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:[NSString stringWithFormat:@"User Not Logged In. Use the Settings page to login"]
                                   delegate:nil
                          cancelButtonTitle:@"OK"otherButtonTitles:nil
          ] show];
        return nil;
    }
    
    NSData *tvmData; //where json data will be put.
    NSError *error;
    NSString *urlQueryString;
    if( password != nil)
    {
        //Password was given, this is not a loginwithamazon session
        urlQueryString = [NSString stringWithFormat:TVM_GET_CREDENTIALS_PATH, email, password];
        urlQueryString = [urlQueryString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    else
    {
    
        //Setup the URl to the token vending machine
        urlQueryString = [NSString stringWithFormat:TVM_GET_CREDENTIALS_OAUTH_PATH, email, name, amznTokenString];
        urlQueryString = [urlQueryString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    NSURL *tvmUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", TVM_HOSTNAME, urlQueryString]];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:tvmUrl];
    NSURLResponse *response;

    //Get token information from the token vending machine
    tvmData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
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
        [[NSUserDefaults standardUserDefaults] synchronize];
        AMZNLogoutDelegate *delegate = [[AMZNLogoutDelegate alloc] init];
        [AIMobileLib clearAuthorizationState:delegate];
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
    [[NSUserDefaults standardUserDefaults] setObject:[json objectForKey:@"fittername"] forKey:USER_DEFAULTS_FITTERNAME_KEY];

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
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    
    if(abs(interval)/60 < AUTHENTICATED_TIMEOUT_MINUTES)
    {
        //
        // If this user is logged in via amazon OAuth, refresh that
        // token first (the callback will call CredentialProvider:Refresh
        // on successful renewal
        //
        if(amznTokenString) {
            //if the token expires in fewer than 10 minutes, refresh it.
            [AIMobileLib getAccessTokenForScopes:[NSArray arrayWithObject:@"profile"]
                              withOverrideParams:nil
                                        delegate:self];
        } else {
            //
            // Refresh the Bikefit Token w/ username
            // and password instead of Amazon Oauth token
            //
            [self refresh];
        }
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

- (void) createNewAccountWithEmail:(NSString *)email
                          password:(NSString *)password
                          shopName:(NSString *)shopName
                         firstName:(NSString *)firstName
                          lastName:(NSString *)lastName
                          callback:(void(^)(BOOL))callback;
{
    NSString *urlQueryString = [NSString stringWithFormat:TVM_CREATE_ACCOUNT_PATH, email, password, shopName,firstName,lastName];
    urlQueryString = [urlQueryString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
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
                    if (callback) {
                        callback(false);
                    }
                    return;
                }
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSString *errorMessage =  [json objectForKey:@"error"];
                if(errorMessage)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:false forKey:USER_DEFAULTS_ACCOUNT_ACTIVE_KEY];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[[UIAlertView alloc] initWithTitle:@""
                                                message:[NSString stringWithFormat:@"Create Account Failed With Message: %@",errorMessage]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"otherButtonTitles:nil
                      ] show];
                    if (callback) {
                        callback(false);
                    }
                } else {
                    [[NSUserDefaults standardUserDefaults] setObject:email forKey:USER_DEFAULTS_USERNAME_KEY];
                    [[NSUserDefaults standardUserDefaults] setObject:shopName forKey:USER_DEFAULTS_FITTERNAME_KEY];
                    [[NSUserDefaults standardUserDefaults] setObject:password forKey:USER_DEFAULTS_PASSWORD_KEY];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self refresh];
                    if (callback) {
                        callback(true);
                    }
                }
            });
        }];
    
    [dataTask resume];
    
}
@end

