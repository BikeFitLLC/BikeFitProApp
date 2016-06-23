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
#import "LoadinSpinnerView.h"

@interface HomeScreenViewController ()
{
    LoadinSpinnerView *loadingView;
    
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
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0x7/255.0 green:0x31/255.0 blue:0x54/255.0 alpha:1.0];
    
    
    self.view.backgroundColor = [UIColor colorWithRed:0x7/255.0 green:0x31/255.0 blue:0x54/255.0 alpha:1.0];
    
    bool loggedIn = [AmazonClientManager verifyLoggedInActive];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BF-Logo"]];
    logoImageView.center = CGPointMake(self.view.center.x, self.view.frame.size.height * .1);
    [self.view addSubview:logoImageView];
    
    clientsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clientsButton setImage:[UIImage imageNamed:@"Clients" ] forState:UIControlStateNormal];
    clientsButton.frame = CGRectMake(0,
                                     self.view.frame.size.height *.5,
                                     clientsButton.imageView.image.size.width,
                                     clientsButton.imageView.image.size.height);

    [clientsButton addTarget:self action:@selector(segueToClientPage:) forControlEvents:UIControlEventTouchUpInside];
    [clientsButton setEnabled:loggedIn];
    [self.view addSubview:clientsButton];
    
    settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setImage:[UIImage imageNamed:@"Customize" ] forState:UIControlStateNormal];
    settingsButton.frame = CGRectMake(self.view.frame.size.width * .5,
                                      self.view.frame.size.height *.5,
                                      settingsButton.imageView.image.size.width,
                                      settingsButton.imageView.image.size.height);
    settingsButton.enabled = NO; //[AmazonClientManager verifyLoggedInActive];
    [self.view addSubview:settingsButton];
    
    UIButton *newFitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newFitButton setImage:[UIImage imageNamed:@"New-Fit" ] forState:UIControlStateNormal];
    newFitButton.frame = CGRectMake(0,
                                    self.view.frame.size.height *.5 - newFitButton.imageView.image.size.height,
                                    newFitButton.imageView.image.size.width,
                                    newFitButton.imageView.image.size.height);
    [newFitButton addTarget:self action:@selector(segueToNewFitPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newFitButton];
    
    sendEmail = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendEmail setImage:[UIImage imageNamed:@"Email" ] forState:UIControlStateNormal];
    sendEmail.frame = CGRectMake(self.view.frame.size.width * .5,
                                 self.view.frame.size.height *.5 - newFitButton.imageView.image.size.height,
                                 sendEmail.imageView.image.size.width,
                                 sendEmail.imageView.image.size.height);
    [sendEmail addTarget:self action:@selector(emailIntakeUrl) forControlEvents:UIControlEventTouchUpInside];
    sendEmail.enabled = loggedIn;
    [self.view addSubview:sendEmail];
    
    [self refreshLoginButtons];

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
                                      self.view.frame.size.height - self.view.frame.size.width * .1,
                                      self.view.frame.size.width,
                                      self.view.frame.size.width * .1);
    if(![AmazonClientManager verifyLoggedIn])
    {
        loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        loginButton.frame = loginoutframe;
        loginButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        loginButton.titleLabel.font = [UIFont systemFontOfSize:28];
        loginButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        loginButton.backgroundColor = [UIColor redColor];
        [loginButton setTitle:@"Please Log In" forState:UIControlStateNormal];
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
        welcomButton.titleLabel.font = [UIFont systemFontOfSize:28];
        welcomButton.titleLabel.adjustsFontSizeToFitWidth = YES;
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
        [logoutButton setImage:[UIImage imageNamed:@"Logout-Cancel"] forState:UIControlStateNormal];
        logoutButton.frame = frame;
        
        logoutButton.center = CGPointMake(self.view.frame.size.width - logoutButton.frame.size.width/2,
                                              welcomButton.center.y);
        [logoutButton addTarget:self action:@selector(logoutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:logoutButton];
        [self.view addSubview:welcomButton];
        
        sendEmail.enabled = YES ;
        clientsButton.enabled= YES ;
        settingsButton.enabled = YES;
        
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
    if([AmazonClientManager verifyLoggedInActive])
    {
        [self performSegueWithIdentifier:@"showfithome" sender:sender];
    }
    else
    {
        [self performSegueWithIdentifier:@"showbikefit" sender:sender];
    }
    
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
    //[[AmazonClientManager credProvider] setIsLoggingIn:true];
    //NSArray *requestScopes = [NSArray arrayWithObject:@"profile"];
    //AMZNAuthorizeUserDelegate* delegate = [[AMZNAuthorizeUserDelegate alloc] initWithParentController:self];

    //[AIMobileLib authorizeUserForScopes:requestScopes delegate:delegate];
    
    [self performSegueWithIdentifier:@"showlogin" sender:sender];
}

- (void)logoutButtonClicked:(id)sender {
    AMZNLogoutDelegate* delegate = [[AMZNLogoutDelegate alloc] initWithParentController:self];
    [AIMobileLib clearAuthorizationState:delegate];
}

- (void)loadSignedInUser
{
    if([AmazonClientManager verifyLoggedInActive])
    {
        //settingsButton.enabled = YES;
        sendEmail.enabled = YES;
        clientsButton.enabled = YES;
    }
    [self refreshLoginButtons];
}

- (void) emailIntakeUrl
{
    MFMailComposeViewController *emailController= [[MFMailComposeViewController alloc] init];
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

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
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
