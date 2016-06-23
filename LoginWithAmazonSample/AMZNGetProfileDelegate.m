/**
 * Copyright 2012-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy
 * of the License is located at
 *
 * http://aws.amazon.com/apache2.0/
 *
 * or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

#import "AMZNGetProfileDelegate.h"
#import "BikefitConstants.h"
#import "AmazonClientManager.h"
#import "AMZNGetAccessTokenDelegate.h"
#import "LoginDelegate.h"

@implementation AMZNGetProfileDelegate

- (id)initWithParentController:(UIViewController<LoginDelegate>*)aViewController {
    if(self = [super init]) {
        parentViewController = aViewController;
    }
    
    return self;
}

#pragma mark Implementation of getProfile: delegates.
- (void)requestDidSucceed:(APIResult *)apiResult {
    // Get profile request succeded. Use the profile information to achieve various use cases like showing a simple welcome message.

    //Set the username and amazon userid
    NSDictionary *userProfile = (NSDictionary*)apiResult.result;
    
    [[NSUserDefaults standardUserDefaults] setObject:[[userProfile objectForKey:@"email"] lowercaseString] forKey:USER_DEFAULTS_USERNAME_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:[userProfile objectForKey:@"name"] forKey:USER_DEFAULTS_FITTERNAME_KEY];
    
    //We have the profile, now lets get the access token
    [AIMobileLib getAccessTokenForScopes:[NSArray arrayWithObject:@"profile"]
                      withOverrideParams:nil
                                delegate:[AmazonClientManager credProvider]];
    
    
    //parentViewController.userProfile = userProfile;
    [parentViewController onUserSignedIn];
}

- (void)requestDidFail:(APIError *)errorResponse {
    // Get Profile request failed for profile scope.

    // If error code = kAIApplicationNotAuthorized, allow user to log in again.
    if(errorResponse.error.code == kAIApplicationNotAuthorized) {
        // Show authorize user button.
        //[parentViewController showLogInPage];
    }
    else {
        // Handle other errors
        [[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Error occured with message: %@", errorResponse.error.message] delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil] show];
    }
}

@end
