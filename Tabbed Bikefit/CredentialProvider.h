//
//  CredentialProvider.h
//  bikefit
//
//  Created by Alfonso Lopez on 5/5/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSRuntime/AWSRuntime.h>

@interface CredentialProvider : NSObject <AmazonCredentialsProvider>
{
    AmazonCredentials *creds;
}

@end
