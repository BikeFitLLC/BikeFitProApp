//
//  LoginViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 10/31/15.
//  Copyright © 2015 Alfonso Lopez. All rights reserved.
//

#import "LoginViewController.h"
#import "BikefitConstants.h"
#import "UIColor+CustomColor.h"

#import <StoreKit/StoreKit.h>

@interface LoginViewController ()
{
    UIButton *loginButton;
    UIButton *newAccountButton;
    UIButton *loginWithAmazonButton;
    UITextField *emailField;
    UITextField *passwordField;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.view.backgroundColor = [UIColor bikeFitBlue];

    float width = CGRectGetWidth(self.view.frame);
    float margin = CGRectGetWidth(self.view.frame) * 0.033;
    //float bottomOfNavBar = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    float fieldHeight = 50;

    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BF-Logo"]];
    logoImageView.center = CGPointMake(self.view.center.x, self.view.frame.size.height * .1);
    [self.view addSubview:logoImageView];

    // Do any additional setup after loading the view.
    emailField = [[UITextField alloc] initWithFrame:CGRectMake(margin,
                                                               CGRectGetMaxY(logoImageView.frame) + margin,
                                                               width - (margin * 2),
                                                               fieldHeight)];
    emailField.borderStyle = UITextBorderStyleRoundedRect;
    emailField.backgroundColor = [UIColor whiteColor];
    emailField.font = [UIFont systemFontOfSize:15];
    emailField.placeholder = @"Email";
    emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    emailField.returnKeyType = UIReturnKeyNext;
    emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [emailField setDelegate:self];
    [self.view addSubview:emailField];
    
    passwordField = [[UITextField alloc] initWithFrame:CGRectMake(margin,
                                                                   CGRectGetMaxY(emailField.frame) + margin,
                                                                   width - (margin * 2),
                                                                   fieldHeight)];
    passwordField.borderStyle = UITextBorderStyleRoundedRect;
    passwordField.backgroundColor = [UIColor whiteColor];
    passwordField.font = [UIFont systemFontOfSize:15];
    passwordField.placeholder = @"Password";
    passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordField.keyboardType = UIKeyboardTypeDefault;
    passwordField.returnKeyType = UIReturnKeyDone;
    passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordField.secureTextEntry = YES;
    [passwordField setDelegate:self];
    [self.view addSubview:passwordField];
    
    loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginButton.frame = CGRectMake(0,
                                   CGRectGetMaxY(passwordField.frame) + (margin * 2),
                                   CGRectGetWidth(self.view.frame),
                                   fieldHeight);
    loginButton.backgroundColor = [UIColor colorWithRed:0x7/255.0 green:0x45/255.0 blue:0x54/255.0 alpha:1.0];
    [loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    newAccountButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    newAccountButton.frame = CGRectMake(0,
                                        CGRectGetMaxY(loginButton.frame) + margin,
                                        CGRectGetWidth(self.view.frame),
                                        fieldHeight);
    newAccountButton.backgroundColor = [UIColor colorWithRed:0x7/255.0 green:0x45/255.0 blue:0x54/255.0 alpha:1.0];
    newAccountButton.hidden = NO;
    [newAccountButton setTitle:@"Create Account" forState:UIControlStateNormal];
    [newAccountButton addTarget:self action:@selector(onCreateAccountClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newAccountButton];
    
    UILabel *supportEmailLabel = [[UILabel alloc] initWithFrame:newAccountButton.frame];
    supportEmailLabel.textAlignment = NSTextAlignmentCenter;
    supportEmailLabel.text = @"support@bikefit.com";
    supportEmailLabel.textColor = [UIColor grayColor];
    //[self.view addSubview:supportEmailLabel];
    
    loginWithAmazonButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginWithAmazonButton.hidden = YES;
    loginWithAmazonButton.frame = loginButton.frame;
    loginWithAmazonButton.backgroundColor = [UIColor colorWithRed:0x7/255.0 green:0x45/255.0 blue:0x54/255.0 alpha:1.0];
    [loginWithAmazonButton setTitle:@"Log In With Amazon" forState:UIControlStateNormal];
    [loginWithAmazonButton addTarget:self action:@selector(loginWithAmazon:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginWithAmazonButton];

    NSString *emailString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_USERNAME_KEY];

    if (emailString) {
        emailField.text = emailString;
    }

    NSString *passwordString = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_PASSWORD_KEY];
    if (passwordString) {
        passwordField.text = passwordString;
    }
}

- (void) login:(id)sender {
    [AmazonClientManager loginWithEmail:emailField.text andPassword:passwordField.text andDelegate:self];
}

- (void) loginWithAmazon:(id)sender
{
    [AmazonClientManager loginWithAmazon:self];
    
}

- (void) onUserSignedIn
{
    if([AmazonClientManager verifyLoggedIn])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    return;
}

- (void)amazonCheckResult:(BOOL)isAmazonAccount accountExists:(BOOL)exists;
{
    if(isAmazonAccount)
    {
        passwordField.hidden = YES;
        loginButton.hidden = YES;
        loginWithAmazonButton.hidden = NO;
        //passwordField.text = @"Please Log In With Amazon";
        //passwordField.secureTextEntry = NO;
    }
    else
    {
        loginButton.hidden = NO;
        passwordField.hidden = NO;
        loginWithAmazonButton.hidden = YES;
        //passwordField.secureTextEntry = YES;
    }
    
    return;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onCreateAccountClicked:(id)sender
{
    [self performSegueWithIdentifier:@"showcreateaccount" sender:sender];
}

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    if (textField == emailField) {
        [passwordField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == emailField)
    {
        loginButton.hidden = NO;
        loginWithAmazonButton.hidden = YES;
        passwordField.hidden = NO;
        passwordField.text = @"";
    }
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == emailField)
    {
        [AmazonClientManager isAmazonAccount:emailField.text andDelegate:self];
    }
}


# pragma mark Store Kit

- (IBAction) subscribe:(id)sender
{
//    SKProduct * product = SKProduct;
//    product.productIdentifier = @"pro_subscription";
    
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
