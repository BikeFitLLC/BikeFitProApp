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

#import <LoginWithAmazon/LoginWithAmazon.h>

#import "AMZNLoginController.h"
#import "AMZNGetAccessTokenDelegate.h"
#import "AMZNGetProfileDelegate.h"
#import "AMZNAuthorizeUserDelegate.h"
#import "AMZNLogoutDelegate.h"
#import "AmazonClientManager.h"
#import "BikefitConstants.h"

@implementation AMZNLoginController

@synthesize userProfile, /*navigationItem,*/ logoutButton, loginButton, infoField;

NSString* userLoggedOutMessage = @"Welcome, BikeFit Pro!\n";

NSString* userLoggedInMessage = @"Logged In As %@";
BOOL isUserSignedIn;

- (IBAction)onLogInButtonClicked:(id)sender {
    // Make authorize call to SDK to get authorization from the user.
    // Requesting 'profile' scopes for the current user.
    NSArray *requestScopes = [NSArray arrayWithObject:@"profile"];
    AMZNAuthorizeUserDelegate* delegate = [[AMZNAuthorizeUserDelegate alloc] initWithParentController:self];
    [AIMobileLib authorizeUserForScopes:requestScopes delegate:delegate];
}

- (IBAction)logoutButtonClicked:(id)sender {
    AMZNLogoutDelegate* delegate = [[AMZNLogoutDelegate alloc] initWithParentController:self];
    [AIMobileLib clearAuthorizationState:delegate];
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark View controller specific functions
- (void)checkIsUserSignedIn {
    AMZNGetAccessTokenDelegate* delegate = [[AMZNGetAccessTokenDelegate alloc] initWithParentController:self];
    [AIMobileLib getAccessTokenForScopes:[NSArray arrayWithObject:@"profile"] withOverrideParams:nil delegate:delegate];
}

- (void)loadSignedInUser {
    //isUserSignedIn = true;
    self.loginButton.hidden = true;
    //self.navigationItem.rightBarButtonItem = self.logoutButton;
   // NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_USERNAME_KEY];
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTERNAME_KEY];
    
    self.infoField.text = [NSString stringWithFormat:@"Logged In As %@", name];
    self.infoField.font = [UIFont fontWithName:@"Gill Sans" size:48.0];
    self.infoField.textColor = [UIColor grayColor];
    self.infoField.textAlignment = NSTextAlignmentCenter;
    self.infoField.hidden = false;
    
    logoutButton.hidden = false;
}

- (void)showLogInPage {
    isUserSignedIn = false;
    self.loginButton.hidden = false;
    self.logoutButton.hidden = true;
    
    onlineModeSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_ONLINEMODE_KEY] boolValue];
    [onlineModeSwitch addTarget:self action:@selector(toggleOnlineSwitch:) forControlEvents:UIControlEventValueChanged];
    
    if(onlineModeSwitch.on)
    {
        self.infoField.text = userLoggedOutMessage;
        self.infoField.hidden = false;
        self.loginButton.enabled = true;
    }
    else
    {
        self.infoField.text = @"Offline Mode";
        self.infoField.hidden = false;
        self.loginButton.enabled = false;
    }
    
    self.infoField.font = [UIFont fontWithName:@"Gill Sans" size:48.0];
    self.infoField.textColor = [UIColor grayColor];
    self.infoField.textAlignment = NSTextAlignmentCenter;
    
    
    
}

- (void)viewDidLoad {
    if ([[AmazonClientManager credProvider] isLoggedIn])
        [self loadSignedInUser];
    else
        [self showLogInPage];
    float systemVersion=[[[UIDevice currentDevice] systemVersion] floatValue];
    if(systemVersion>=7.0f)
    {
        CGRect tempRect;
        for(UIView *sub in [[self view] subviews])
        {
            tempRect = [sub frame];
            tempRect.origin.y += 20.0f; //Height of status bar
            [sub setFrame:tempRect];
        }
    }
}

////////////////////////////////////////////
//Called with the onlineMode toggle switch changes
//state
////////////////////////////////////////////
- (void) toggleOnlineSwitch:(id)sender
{
    UISwitch *sendinSwitch = sender;
    [[NSUserDefaults standardUserDefaults] setBool:sendinSwitch.on forKey:USER_DEFAULTS_ONLINEMODE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self showLogInPage];
}

- (void)dealloc {
    //self.navigationItem = nil;
    self.infoField = nil;
    self.loginButton = nil;
    self.logoutButton = nil;
    self.userProfile = nil;
    
}

@end
