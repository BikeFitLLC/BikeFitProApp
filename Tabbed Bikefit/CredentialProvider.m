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

- (AmazonCredentials *)credentials
{
    if(!creds)
    {
        [self refresh];
    }
    return creds;
}

- (void)refresh
{
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_USERNAME_KEY];
    NSString *amazonToken = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_AMZN_TOKEN_KEY];
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTERNAME_KEY];
    
    if( email == nil)
    {
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:[NSString stringWithFormat:@"User Not Logged In. Use the Settings page to login"]
                                   delegate:nil
                          cancelButtonTitle:@"OK"otherButtonTitles:nil
          ] show];
        return;
    }
    
    //Get temporary credentials from the token vending machine via https
    NSString *urlstring = [NSString stringWithFormat:TOKEN_VENDING_MACHINE_URL_FORMAT, email, name, amazonToken];
    NSURL *tvmUrl = [NSURL URLWithString:[urlstring stringByAddingPercentEscapesUsingEncoding : NSUTF8StringEncoding]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:tvmUrl];
    NSURLResponse *response;
    NSError *error;
    NSData *tvmData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error)
    {
        NSLog(@"Error getting credentials from TVM. %@", [error description]);
        creds = [[AmazonCredentials alloc] init];
        return;
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
        
        return;
    }
    
    if(error)
    {
        NSLog(@"Error getting credentials from TVM: %@", [error description]);
        creds = [[AmazonCredentials alloc] init];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:USER_DEFAULTS_ACCOUNT_ACTIVE_KEY];
    [[NSUserDefaults standardUserDefaults] setBool:[[json objectForKey:@"trial"] boolValue] forKey:USER_DEFAULTS_IS_TRIAL_ACCOUNT];
    
    
    creds = [[AmazonCredentials alloc]
             initWithAccessKey:[json objectForKey:@"accesskey"]
             withSecretKey:[json objectForKey:@"secretkey"]
             withSecurityToken:[json objectForKey:@"token"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSString *date = [json objectForKey:@"expiration"];
    tokenExpiration = [dateFormatter dateFromString:date];
    
    
    //Now we have a good response from the TVM.  Populate credentials and Fitterid
    [[NSUserDefaults standardUserDefaults] setObject:[json objectForKey:@"fitterid"] forKey:USER_DEFAULTS_FITTERID_KEY];
    //[[NSUserDefaults standardUserDefaults] setBool:true forKey:USER_DEFAULTS_ONLINEMODE_KEY];
    
}

- (bool) isLoggedIn
{
    return creds != nil;
}

//////////////////////////////////////
//Returns true if the credential token is not expired
//false otherwise
///////////////////////////////////////
-(bool) isTokenValid
{
    return [tokenExpiration compare:[NSDate date]] != NSOrderedAscending;
}

- (void) clear
{
    creds = nil;
}

@end
