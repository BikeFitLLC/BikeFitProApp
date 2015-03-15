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

//NSString* userLoggedInMessage = @"Logged In As %@";
BOOL isUserSignedIn;

- (IBAction)onLogInButtonClicked:(id)sender {
    // Make authorize call to SDK to get authorization from the user.
    // Requesting 'profile' scopes for the current user.
    [[AmazonClientManager credProvider] setIsLoggingIn:true];
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
    self.loginButton.hidden = true;
    
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTERNAME_KEY];
    bool isTrialUser = [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_IS_TRIAL_ACCOUNT];
    
    NSString *message;
    if(isTrialUser)
    {
        message = [NSString stringWithFormat:@"Logged In As %@ \n \n In addition to the BikeFit App you receive 3 months free web services. \n\n To sign up for continued web services please contact education@bikefit.com", name];
    }
    else
    {
        message = [NSString stringWithFormat:@"Logged In As %@", name];
    }

    
    self.infoField.text = message;
    self.infoField.font = [UIFont fontWithName:@"Gill Sans" size:32];
    self.infoField.textColor = [UIColor grayColor];
    self.infoField.textAlignment = NSTextAlignmentCenter;
    self.infoField.hidden = false;
    logoutButton.hidden = false;
    emailIntakeUrlButton.hidden = false;
}

- (void)showLogInPage {
    isUserSignedIn = false;
    self.loginButton.hidden = false;
    self.logoutButton.hidden = true;

    
   //if(onlineModeSwitch.on)
    {
        self.infoField.text = userLoggedOutMessage;
        self.infoField.hidden = false;
        self.loginButton.enabled = true;
    }
    /*else
    {
        self.infoField.text = @"Offline Mode";
        self.infoField.hidden = false;
        self.loginButton.enabled = false;
    }*/
    
    self.infoField.font = [UIFont fontWithName:@"Gill Sans" size:48.0];
    self.infoField.textColor = [UIColor grayColor];
    self.infoField.textAlignment = NSTextAlignmentCenter;
    
    
    
}

- (void)viewDidLoad {
    [onlineModeSwitch addTarget:self action:@selector(toggleOnlineSwitch:) forControlEvents:UIControlEventValueChanged];
    
    UIImageView *logoImage = [[UIImageView alloc] init];
    logoImage.frame = CGRectMake(
                                 self.view.frame.size.width * .1,
                                 0,
                                 self.view.frame.size.width *.8,
                                 self.view.frame.size.width *.3);
    logoImage.image = [UIImage imageNamed:@"BikeFit_logo_Horiz.png"];
    [self.view addSubview:logoImage];
    
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(0,0,
                                   209,
                                   48);
    [loginButton setBackgroundImage:[UIImage imageNamed:@"btnLWA_gold_209x48.png"] forState:UIControlStateNormal];
    [loginButton setCenter:CGPointMake(
                                       self.view.bounds.size.width * .5,
                                       self.view.bounds.size.height *.5)];
    [loginButton addTarget:self action:@selector(onLogInButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    infoField = [[UITextView alloc] init];
    infoField.frame = CGRectMake(
                                self.view.frame.size.width * .5,
                                self.view.frame.size.height * .3,
                                self.view.frame.size.width *.5,
                                self.view.frame.size.width *.5);

    
    //Create label to display the url for this fit
    emailIntakeUrlButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [emailIntakeUrlButton setFrame:CGRectMake(
                                              self.view.frame.size.width * .5,
                                              self.view.frame.size.height * .8,
                                              self.view.frame.size.width *.2,
                                              self.view.frame.size.width *.1)];
    emailIntakeUrlButton.titleLabel.font = [UIFont systemFontOfSize:24];
    emailIntakeUrlButton.backgroundColor = [UIColor blackColor];
    emailIntakeUrlButton.alpha = .5;
    [emailIntakeUrlButton setTitle:@"Email Intake Form" forState:UIControlStateNormal];
    [emailIntakeUrlButton addTarget:self
                             action:@selector(emailIntakeUrl)
                   forControlEvents:UIControlEventTouchUpInside];
    emailIntakeUrlButton.hidden = YES;
    emailIntakeUrlButton.enabled = YES;
    [self.view addSubview:emailIntakeUrlButton];
    
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


- (void) emailIntakeUrl
{
    emailController= [[MFMailComposeViewController alloc] init];
    emailController.mailComposeDelegate = self;
    NSString *fitterName = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTERNAME_KEY];
    NSString *url = [NSString stringWithFormat:@"http://intake.bikefit.com/?fitter=%@", [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_USERNAME_KEY]];
    NSString *emailSubject = [NSString stringWithFormat:@"Intake Form for fit with %@",fitterName];
    NSString *emailMessage = [NSString stringWithFormat:@"Please fill this out before your appointment. <br /><br /><a href=\"%@\">%@</a>", url,url];
    
    [emailController setToRecipients:[NSArray arrayWithObject:[AthletePropertyModel getProperty:AWS_FIT_ATTRIBUTE_EMAIL ]]];
    [emailController setSubject:emailSubject];
    [emailController setMessageBody:emailMessage isHTML:YES];
    if (emailController)
    {
        [self presentViewController:emailController animated:YES completion:NULL];
    }
}

-(void) viewWillAppear:(BOOL)animated
{

}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [emailController dismissViewControllerAnimated:YES completion:NULL];
}

////////////////////////////////////////////
//Called with the onlineMode toggle switch changes
//state
////////////////////////////////////////////
- (void) toggleOnlineSwitch:(id)sender
{
    UISwitch *sendingSwitch = sender;
    [AthletePropertyModel setOfflineMode:!sendingSwitch.on];
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
