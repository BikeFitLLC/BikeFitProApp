//
//  CredentialProvider.m
//  bikefit
//
//  Created by Alfonso Lopez on 5/5/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "CredentialProvider.h"
#import "BikefitConstants.h"

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
    NSString *key = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTER_KEY_KEY];
    
    NSURL *tvmUrl = [NSURL URLWithString:[NSString stringWithFormat:TOKEN_VENDING_MACHINE_URL_FORMAT, key]];
    NSData *tvmData = [NSData dataWithContentsOfURL:tvmUrl];
    
    if(!tvmData)
    {
        NSLog(@"Error getting credentials from TVM.  Empty Response. URL Error?");
        creds = [[AmazonCredentials alloc] init];
        return;
    }
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:tvmData options:NSJSONReadingMutableContainers error:&error];
    
    if(error)
    {
        NSLog(@"Error getting credentials from TVM: %@", [error description]);
        creds = [[AmazonCredentials alloc] init];
        return;
    }
    
    creds = [[AmazonCredentials alloc]
             initWithAccessKey:[json objectForKey:@"accesskey"]
             withSecretKey:[json objectForKey:@"secretkey"]
             withSecurityToken:[json objectForKey:@"token"]];
    
    //Now we have a good response from the TVM.  Populate credentials and Fitterid
    [[NSUserDefaults standardUserDefaults] setObject:[json objectForKey:@"fitterid"] forKey:USER_DEFAULTS_FITTERID_KEY];
    
}

@end
