//
//  HomeScreenViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 8/31/15.
//  Copyright (c) 2015 Alfonso Lopez. All rights reserved.
//

#import "HomeScreenViewController.h"
#import "AMZNAuthorizeUserDelegate.h"
#import "AMZNLogoutDelegate.h"
#import "BikefitConstants.h"

@interface HomeScreenViewController ()
{
    UIButton *clientsButton;
    UIButton *settingsButton;
    UIButton *sendEmail;
    UIButton *loginButton;
    UIButton *welcomButton;
    UIButton *logoutButton;
}

@end

@implementation HomeScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    
    CGFloat buttonwidth = self.view.frame.size.width *.5;
    self.view.backgroundColor = [UIColor colorWithRed:0x7/255.0 green:0x31/255.0 blue:0x54/255.0 alpha:1.0];
    
    bool loggedIn = [AmazonClientManager verifyUserKey];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BF-Logo-1x.png"]];
    logoImageView.center = CGPointMake(self.view.center.x, self.view.frame.size.height * .1);
    [self.view addSubview:logoImageView];
    
     clientsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    clientsButton.frame = CGRectMake(0,
                                     self.view.frame.size.height *.5,
                                     buttonwidth,
                                     buttonwidth);
    [clientsButton setImage:[UIImage imageNamed:@"Clients-1x.png" ] forState:UIControlStateNormal];
    [clientsButton addTarget:self action:@selector(segueToClientPage:) forControlEvents:UIControlEventTouchUpInside];
    [clientsButton setEnabled:loggedIn];
    [self.view addSubview:clientsButton];
    
    
    
    settingsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    settingsButton.frame = CGRectMake(buttonwidth,
                                      self.view.frame.size.height *.5,
                                      buttonwidth,
                                      buttonwidth);
    [settingsButton setImage:[UIImage imageNamed:@"Settings-1x.png" ] forState:UIControlStateNormal];
    settingsButton.enabled = [AmazonClientManager verifyUserKey];
    [self.view addSubview:settingsButton];
    
    UIButton *newFitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    newFitButton.frame = CGRectMake(0,
                                    self.view.frame.size.height *.5 - buttonwidth,
                                    buttonwidth,
                                    buttonwidth);
    [newFitButton setImage:[UIImage imageNamed:@"New-Fit-1x.png" ] forState:UIControlStateNormal];
    [newFitButton addTarget:self action:@selector(segueToNewFitPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newFitButton];
    
    sendEmail = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendEmail.frame = CGRectMake(buttonwidth,
                                 self.view.frame.size.height *.5 - buttonwidth,
                                 buttonwidth,
                                 buttonwidth);
    [sendEmail setImage:[UIImage imageNamed:@"Email-1x.png" ] forState:UIControlStateNormal];
    sendEmail.enabled = loggedIn;
    [self.view addSubview:sendEmail];
    
    [self refreshLoginButtons];
    


}

- (void) refreshLoginButtons
{
    //
    //login/out buttons
    //
    [loginButton removeFromSuperview];
    [welcomButton removeFromSuperview];
    CGRect loginoutframe = CGRectMake(0,
                                      self.view.frame.size.height - self.view.frame.size.width * .2,
                                      self.view.frame.size.width,
                                      self.view.frame.size.width * .2);
    if(![AmazonClientManager verifyUserKey])
    {
        loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        loginButton.frame = loginoutframe;
        [loginButton setImage:[UIImage imageNamed:@"Please-Log-In-1x.png" ] forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(onLogInButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:loginButton];
        sendEmail.enabled = NO ;
        clientsButton.enabled= NO ;
        settingsButton.enabled = NO;
    }
    else
    {
        welcomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        welcomButton.frame = loginoutframe;
        welcomButton.backgroundColor = [UIColor colorWithRed:0x29/255.0 green:0x65/255.0 blue:0x135/255.0 alpha:1.0];
        [welcomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTERNAME_KEY];
        [welcomButton setTitle:[NSString stringWithFormat:@"Welcome %@", name]  forState:UIControlStateNormal];
        
        
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleWelcomSwipeLeft:)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        [welcomButton addGestureRecognizer:recognizer];
        
        UISwipeGestureRecognizer *recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleWelcomSwipeRight:)];
        [recognizerRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [welcomButton addGestureRecognizer:recognizerRight];
        
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width *.2, welcomButton.frame.size.height);
        logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [logoutButton setImage:[UIImage imageNamed:@"Logout-Cancel-Button-1x.png"] forState:UIControlStateNormal];
        logoutButton.frame = frame;
        
        logoutButton.center = CGPointMake(self.view.frame.size.width - logoutButton.frame.size.width/2,
                                              welcomButton.center.y);
        [logoutButton addTarget:self action:@selector(logoutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:logoutButton];
        [self.view addSubview:welcomButton];
        
    }
}

-(void) handleWelcomSwipeLeft:(id)sender
{
    
    if(welcomButton.center.x == self.view.center.x)
    {
        [UIView animateWithDuration:0.5 animations:^{
            welcomButton.center = CGPointMake(welcomButton.center.x - logoutButton.frame.size.width,
                                              welcomButton.center.y);
        }];
    }
}

-(void) handleWelcomSwipeRight:(id)sender
{
    if(welcomButton.center.x != self.view.center.x)
    {
        [UIView animateWithDuration:0.5 animations:^{
            welcomButton.center = CGPointMake(welcomButton.center.x + logoutButton.frame.size.width,
                                              welcomButton.center.y);
        }];
    }
}

-(void)segueToNewFitPage:(id)sender
{
    [AthletePropertyModel newAthlete];
    [self performSegueWithIdentifier:@"showbikefit" sender:sender];
}

-(void)segueToClientPage:(id)sender
{
    [self performSegueWithIdentifier:@"showclientlist" sender:sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLogInButtonClicked:(id)sender
{
    // Make authorize call to SDK to get authorization from the user.
    // Requesting 'profile' scopes for the current user.
    [[AmazonClientManager credProvider] setIsLoggingIn:true];
    NSArray *requestScopes = [NSArray arrayWithObject:@"profile"];
    AMZNAuthorizeUserDelegate* delegate = [[AMZNAuthorizeUserDelegate alloc] initWithParentController:self];
    //loadingView = [[LoadinSpinnerView alloc] initWithFrame:self.view.frame];
    //[self.view addSubview:loadingView];
    [AIMobileLib authorizeUserForScopes:requestScopes delegate:delegate];
}

- (void)logoutButtonClicked:(id)sender {
    AMZNLogoutDelegate* delegate = [[AMZNLogoutDelegate alloc] initWithParentController:self];
    [AIMobileLib clearAuthorizationState:delegate];
}

- (void)loadSignedInUser
{
    if([AmazonClientManager verifyUserKey])
    {
        settingsButton.enabled = YES;
        sendEmail.enabled = YES;
        clientsButton.enabled = YES;
    }
    [self refreshLoginButtons];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
