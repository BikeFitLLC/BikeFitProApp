//
//  LoginViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 10/31/15.
//  Copyright © 2015 Alfonso Lopez. All rights reserved.
//

#import "LoginViewController.h"
#import "BikefitConstants.h"

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
     self.view.backgroundColor = [UIColor colorWithRed:0x7/255.0 green:0x31/255.0 blue:0x54/255.0 alpha:1.0];
    
    // Do any additional setup after loading the view.
    emailField = [[UITextField alloc] initWithFrame:CGRectMake(0,
                                                               0,
                                                               self.view.frame.size.width * .8,
                                                               self.view.frame.size.width * .15)];
    emailField.center = CGPointMake(self.view.center.x, self.view.center.y - self.view.frame.size.width * .1);
    emailField.borderStyle = UITextBorderStyleRoundedRect;
    emailField.backgroundColor = [UIColor whiteColor];
    emailField.font = [UIFont systemFontOfSize:15];
    emailField.placeholder = @"Email";
    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailField.keyboardType = UIKeyboardTypeDefault;
    emailField.returnKeyType = UIReturnKeyDone;
    emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [emailField setDelegate:self];
    [self.view addSubview:emailField];
    
    passwordField = [[UITextField alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  self.view.frame.size.width * .8,
                                                                  self.view.frame.size.width * .15)];
    passwordField.center = CGPointMake(self.view.center.x, self.view.center.y + self.view.frame.size.width * .1);
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
    loginButton.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.width * .1);
    loginButton.backgroundColor = [UIColor colorWithRed:0x7/255.0 green:0x45/255.0 blue:0x54/255.0 alpha:1.0];
    loginButton.center = CGPointMake(self.view.center.x, self.view.center.y + self.view.frame.size.height *.2);
    [loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    newAccountButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    newAccountButton.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.width * .1);
    newAccountButton.backgroundColor = [UIColor colorWithRed:0x7/255.0 green:0x45/255.0 blue:0x54/255.0 alpha:1.0];
    newAccountButton.center = CGPointMake(self.view.center.x, self.view.center.y + self.view.frame.size.height *.3);
    newAccountButton.hidden = NO;
    [newAccountButton setTitle:@"Create Account" forState:UIControlStateNormal];
    [newAccountButton addTarget:self action:@selector(onCreateAccountClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newAccountButton];
    
    loginWithAmazonButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginWithAmazonButton.hidden = YES;
    loginWithAmazonButton.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.width * .1);
    loginWithAmazonButton.backgroundColor = [UIColor colorWithRed:0x7/255.0 green:0x45/255.0 blue:0x54/255.0 alpha:1.0];
    loginWithAmazonButton.center = loginButton.center;
    [loginWithAmazonButton setTitle:@"Log In With Amazon" forState:UIControlStateNormal];
    [loginWithAmazonButton addTarget:self action:@selector(loginWithAmazon:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginWithAmazonButton];
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
    [textField resignFirstResponder];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
