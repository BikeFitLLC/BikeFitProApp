//
//  AMZNAuthorizeUserDelegate.m
//  bikefit
//
//  Created by Alfonso Lopez on 5/11/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "AMZNAuthorizeUserDelegate.h"

@implementation AMZNAuthorizeUserDelegate

- (id)initWithParentController:(AMZNLoginController*)aViewController {
    if(self = [super init]) {
        parentViewController = [aViewController retain];
    }
    
    return self;
}


#pragma mark Implementation of authorizeUserForScopes:delegate: delegates.
/*
 Delegate method that gets a call when the user authoriation for requested scope succeeds. Define you logic for changing the User interface on being able to recogize the user.
 */
- (void)requestDidSucceed:(APIResult *)apiResult {
    // Your code after the user authorizes Application for requested scopes.
    
    // You can now load new view controller with user identifying information as the user is now successfully signed in or simple get the user profile information if the authorization was for "profile" scope.
    
    //AMZNGetProfileDelegate* delegate = [[[AMZNGetProfileDelegate alloc] initWithParentController:parentViewController] autorelease];
    //[AIMobileLib getProfile:delegate];
}

/*
 Delegate method that gets a call when the user authoriation for requested scope fails.
 */
- (void)requestDidFail:(APIError *)errorResponse {
    // Your code when the authorization fails.
    
    [[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"User authorization failed with message: %@", errorResponse.error.message] delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil] show];
}

@end
