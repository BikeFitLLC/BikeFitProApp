//
//  FitHome.m
//  bikefit
//
//  Created by Alfonso Lopez on 8/31/15.
//  Copyright (c) 2015 Alfonso Lopez. All rights reserved.
//

#import "FitHome.h"
#import "BikefitConstants.h"
#import "UIColor+CustomColor.h"
#import "AWSSyncErrorManager.h"
#import "SVProgressHUD.h"

@interface FitHome () <LoginDelegate>
{
    UIButton *athleteInfoButton;
    UIButton *bikeFitButton;
    UIButton *measurementButton;
    UIButton *emailFitButton;
    UIButton *viewFitButton;
    MFMailComposeViewController* emailController;
    UIButton *syncButton;
}

@end

@implementation FitHome

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateErrorState)
                                                 name:kNotificationAWSSync
                                               object:nil];
    [self updateErrorState];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationAWSSync
                                                  object:nil];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bikeFitBlue];
    
    
    CGRect namelabelframe = CGRectMake(0,
                                      self.navigationController.navigationBar.frame.size
                                       .height,
                                      self.view.frame.size.width,
                                      self.view.frame.size.width * .1);

    UILabel *nameLabel = [[UILabel alloc] initWithFrame:namelabelframe];
    nameLabel.backgroundColor = [UIColor colorWithRed:0x29/255.0 green:0x65/255.0 blue:0x135/255.0 alpha:1.0];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont systemFontOfSize:36];
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.text = [NSString stringWithFormat:@"%@ %@", [AthletePropertyModel getProperty:AWS_FIT_ATTRIBUTE_FIRSTNAME],
                      [AthletePropertyModel getProperty:AWS_FIT_ATTRIBUTE_LASTNAME]];
    [self.view addSubview:nameLabel];
    
    bikeFitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bikeFitButton setImage:[UIImage imageNamed:@"Fitting" ] forState:UIControlStateNormal];
    bikeFitButton.frame = CGRectMake(self.view.center.x - bikeFitButton.imageView.image.size.width * .5,
                                         self.view.center.y - bikeFitButton.imageView.image.size.height,
                                         bikeFitButton.imageView.image.size.width,
                                         bikeFitButton.imageView.image.size.height);

    [bikeFitButton addTarget:self action:@selector(segueToBikeFit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bikeFitButton];
    
    athleteInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [athleteInfoButton setImage:[UIImage imageNamed:@"Basic-Info" ] forState:UIControlStateNormal];
    athleteInfoButton.frame = CGRectMake(bikeFitButton.frame.origin.x,
                                         bikeFitButton.frame.origin.y - athleteInfoButton.imageView.image.size.height,
                                         athleteInfoButton.imageView.image.size.width,
                                         athleteInfoButton.imageView.image.size.height);

    [athleteInfoButton addTarget:self action:@selector(segueToAthleteInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:athleteInfoButton];
    
    measurementButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [measurementButton setImage:[UIImage imageNamed:@"Measurement" ] forState:UIControlStateNormal];
    measurementButton.frame = CGRectMake(bikeFitButton.frame.origin.x,
                                         bikeFitButton.frame.origin.y + bikeFitButton.imageView.image.size.height,
                                         measurementButton.imageView.image.size.width,
                                         measurementButton.imageView.image.size.height);
    [measurementButton addTarget:self action:@selector(segueToMeasurements:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:measurementButton];
    
    emailFitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [emailFitButton setImage:[UIImage imageNamed:@"View-Fit" ] forState:UIControlStateNormal];
    emailFitButton.frame = CGRectMake(measurementButton.frame.origin.x,
                                         measurementButton.frame.origin.y + measurementButton.imageView.image.size.height,
                                         emailFitButton.imageView.image.size.width,
                                         emailFitButton.imageView.image.size.height);

    [emailFitButton addTarget:self action:@selector(openFitUrl) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:emailFitButton];
    
    viewFitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [viewFitButton setImage:[UIImage imageNamed:@"Email-Fit" ] forState:UIControlStateNormal];
    viewFitButton.frame = CGRectMake(emailFitButton.frame.origin.x,
                                      emailFitButton.frame.origin.y + emailFitButton.imageView.image.size.height,
                                      viewFitButton.imageView.image.size.width,
                                      viewFitButton.imageView.image.size.height);
    
    [viewFitButton addTarget:self action:@selector(emailFit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:viewFitButton];
    
    syncButton = [UIButton buttonWithType:UIButtonTypeCustom];
    syncButton.frame = CGRectMake(viewFitButton.frame.origin.x,
                                  CGRectGetMaxY(viewFitButton.frame),
                                  viewFitButton.imageView.image.size.width,
                                  self.view.bounds.size.height - CGRectGetMaxY(viewFitButton.frame));
    syncButton.backgroundColor = [UIColor colorWithRed:0.8 green:0 blue:0.5 alpha:1];
    [syncButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [syncButton setTitle:@"Press to sync with server" forState:UIControlStateNormal];
    [syncButton addTarget:self action:@selector(sync) forControlEvents:UIControlEventTouchUpInside];
    syncButton.hidden = true;
    [self.view addSubview:syncButton];
}

-(void)segueToAthleteInfo:(id)sender
{
    [self performSegueWithIdentifier:@"showathleteinfo" sender:sender];
}
-(void)segueToBikeFit:(id)sender
{
    [self performSegueWithIdentifier:@"showbikefit" sender:sender];
}
-(void)segueToMeasurements:(id)sender
{
    [self performSegueWithIdentifier:@"showmeasurements" sender:sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) emailFit:(id)sender
{
    emailController= [[MFMailComposeViewController alloc] init];
    emailController.mailComposeDelegate = self;
    NSString *fitterName = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTERNAME_KEY];
    NSString *url = [[AthletePropertyModel getProperty:AWS_FIT_ATTRIBUTE_URL] lowercaseString];
    NSString *emailSubject = [NSString stringWithFormat:@"Your Fit from %@",fitterName];
    NSString *emailMessage = [NSString stringWithFormat:@"Thanks for coming in! <br /><br /><a href=\"%@\">Click to view your fit</a>", url];
    
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
    [emailController dismissViewControllerAnimated:YES completion:NULL];
}

- (void) openFitUrl
{
    NSString *url = [[AthletePropertyModel getProperty:AWS_FIT_ATTRIBUTE_URL] lowercaseString];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark - error state

- (void)updateErrorState
{
    //yay
    NSString *athleteWithError = [AWSSyncErrorManager athleteWithError];
    if (athleteWithError && [athleteWithError isEqualToString:[AthletePropertyModel athleteIdentifier]]) {
        //show sync button
        syncButton.hidden = false;
    } else {
        //hide
        syncButton.hidden = true;
        
        if (![[AmazonClientManager credProvider] isTokenValid]) {
            [self showLoginError];
        }
    }
}

- (void)sync
{
    [SVProgressHUD showWithStatus:@"Syncing with server..."];
    [AthletePropertyModel saveAthleteToAWS:^(BOOL success, BOOL loginError) {
        [SVProgressHUD dismiss];
        if (success) {
            [self updateErrorState];
        } else {
            if (loginError) {
                // do login thing
                [self showLoginError];
            } else {
                // show sync error
                UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self sync];
                }];
                [self amazonUploadErrorAlertController:nil
                                           retryAction:retryAction];
            }
        }
    }];
}

- (void)showLoginError
{
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self startLogin];
    }];
    [self amazonUploadErrorAlertController:@"You are not logged in"
                               retryAction:retryAction];
}

- (void)amazonUploadErrorAlertController:(NSString *)errorMessage retryAction:(UIAlertAction *)retryAction
{
    if (!errorMessage) {
        errorMessage = @"We're sorry, we could not sync the data with the server.  Please make sure you have a stable internet connection and try again";
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"An upload error has occurred"
                                                                             message:errorMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:retryAction];
    [self.navigationController presentViewController:alertController
                                            animated:true
                                          completion:nil];
}

- (void)startLogin
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please confirm your login credentials"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_USERNAME_KEY];
        textField.placeholder = @"Email";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.secureTextEntry = NO;
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_PASSWORD_KEY];
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"Login"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [self loginWithCredentials:[[alertController textFields][0] text]
                                                                              password:[[alertController textFields][1] text]];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:loginAction];
    
    [self.navigationController presentViewController:alertController
                                            animated:true
                                          completion:nil];
}

- (void)loginWithCredentials:(NSString *)email password:(NSString *)password
{
    [SVProgressHUD showWithStatus:@"Logging in..."];
    [AmazonClientManager loginWithEmail:email
                            andPassword:password
                            andDelegate:self];
}

- (void)onUserSignedIn
{
    [SVProgressHUD dismiss];
    [self sync];
}

@end
