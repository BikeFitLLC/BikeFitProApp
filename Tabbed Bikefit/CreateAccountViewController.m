//
//  CreateAccountViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 11/4/15.
//  Copyright © 2015 Alfonso Lopez. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "UIColor+CustomColor.h"
#import "SVProgressHUD.h"

@interface CreateAccountViewController ()
{
    UITextField *firstNameField;
    UITextField *lastNameField;
    UITextField *emailField;
    UITextField *shopNameField;
    UITextField *passwordFieldOne;
    UITextField *passwordFieldTwo;
    UIButton *createButton;
}

@end

@implementation CreateAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bikeFitBlue];

    float width = CGRectGetWidth(self.view.frame);
    float margin = CGRectGetWidth(self.view.frame) * 0.033;
    float bottomOfNavBar = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    float fieldHeight = 50;

    firstNameField = [[UITextField alloc] initWithFrame:CGRectMake(margin,
                                                                  bottomOfNavBar + margin,
                                                                  width - (margin * 2),
                                                                  fieldHeight)];
    firstNameField.placeholder = @"First Name";
    [self applyTextFieldDefaults:firstNameField];
    firstNameField.hidden = YES;
    [self.view addSubview:firstNameField];

    lastNameField = [[UITextField alloc] initWithFrame:CGRectMake(margin,
                                                               CGRectGetMaxY(firstNameField.frame) + margin,
                                                               width - (margin * 2),
                                                               fieldHeight)];
    lastNameField.placeholder = @"Last Name";
    [self applyTextFieldDefaults:lastNameField];
    lastNameField.hidden = YES;
    [self.view addSubview:lastNameField];

    emailField = [[UITextField alloc] initWithFrame:CGRectMake(margin,
                                                               CGRectGetMaxY(lastNameField.frame) + margin,
                                                               width - (margin * 2),
                                                               fieldHeight)];
    emailField.placeholder = @"Email";
    [self applyTextFieldDefaults:emailField];
    emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    [self.view addSubview:emailField];
    
    shopNameField = [[UITextField alloc] initWithFrame:CGRectMake(margin,
                                                                  CGRectGetMaxY(emailField.frame) + margin,
                                                                  width - (margin * 2),
                                                                  fieldHeight)];
    shopNameField.placeholder = @"Shop Name";
    [self applyTextFieldDefaults:shopNameField];
    shopNameField.hidden = YES;
    [self.view addSubview:shopNameField];
    
    passwordFieldOne = [[UITextField alloc] initWithFrame:CGRectMake(margin,
                                                                     CGRectGetMaxY(shopNameField.frame) + margin,
                                                                     width - (margin * 2),
                                                                     fieldHeight)];
    passwordFieldOne.placeholder = @"Password";
    passwordFieldOne.secureTextEntry = TRUE;
    [self applyTextFieldDefaults:passwordFieldOne];
    [passwordFieldOne addTarget:self action:@selector(textFieldDidEndEditing:)
        forControlEvents:UIControlEventEditingChanged];
    passwordFieldOne.hidden = YES;
    [self.view addSubview:passwordFieldOne];
    
    passwordFieldTwo = [[UITextField alloc] initWithFrame:CGRectMake(margin,
                                                                     CGRectGetMaxY(passwordFieldOne.frame) + margin,
                                                                     width - (margin * 2),
                                                                     fieldHeight)];
    passwordFieldTwo.secureTextEntry = YES;
    passwordFieldTwo.placeholder = @"Password";
    [self applyTextFieldDefaults:passwordFieldTwo];
    passwordFieldTwo.returnKeyType = UIReturnKeyDone;
    [passwordFieldTwo addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingChanged];
    passwordFieldTwo.hidden = YES;
    [self.view addSubview:passwordFieldTwo];
    
    createButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    createButton.frame = CGRectMake(0,
                                    CGRectGetMaxY(passwordFieldTwo.frame) + (margin * 2),
                                    CGRectGetWidth(self.view.frame),
                                    fieldHeight);
    createButton.backgroundColor = [UIColor colorWithRed:0x7/255.0 green:0x45/255.0 blue:0x54/255.0 alpha:1.0];
    createButton.hidden = YES;
    [createButton setTitle:@"Create Account" forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(createAccount:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createButton];


    // Do any additional setup after loading the view.
    
}

- (void) viewWillAppear:(BOOL)animated {
    [SVProgressHUD showWithStatus:@"Initializing"];
    [[SubcriptionManager sharedManager] setDelegate:self];
    [[SubcriptionManager sharedManager] retrieveAvailableProducts];
    
}

- (void)applyTextFieldDefaults:(UITextField *)textField
{
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.backgroundColor = [UIColor whiteColor];
    textField.font = [UIFont systemFontOfSize:15];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.returnKeyType = UIReturnKeyNext;
    textField.delegate = self;
}

-(void)createAccount:(id)sender
{
    if ([self textsFieldsValid]) {
        [SVProgressHUD showWithStatus:@"Creating account"];
        //
        // Create New Account on Bikefit Backend (this will be a trial account)
        //
        UserInfo *userInfo = [UserInfo userInfoWithEmail:emailField.text
                                               firstName:firstNameField.text
                                                lastName:lastNameField.text
                                                password:passwordFieldOne.text
                                                shopName:shopNameField.text
                                                fitterid:nil
                                           transactionid:nil];
        
        //TODO Refactor createNewAccount to take userinfo
        __weak __typeof__(self) weakSelf = self;
        [[AmazonClientManager credProvider] createNewAccountWithEmail:userInfo.email
                                                             password:userInfo.password
                                                             shopName:userInfo.shopName
                                                            firstName:userInfo.firstname
                                                             lastName:userInfo.lastName
             callback:^(BOOL success) {
                 if ( success ) {
                     NSLog(@"Created Account for %@, logging in", userInfo.email);
                     [AmazonClientManager loginWithEmail:userInfo.email andPassword:userInfo.password andDelegate:weakSelf];
                
                 } else {
                     NSError *error = [NSError errorWithDomain:@"Bikefit"
                                                          code:1
                                                      userInfo:@{@"description":@"Failed to create bikefit account"}];
                 }
             }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"All fields must be filled out"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == passwordFieldOne || textField == passwordFieldTwo)
    {
        if(![passwordFieldOne.text isEqualToString:@""] && [passwordFieldOne.text isEqualToString:passwordFieldTwo.text])
        {
            createButton.enabled = YES;
        }
        else{
            createButton.enabled = NO;
        }
    }
    if( textField == emailField )
    {
        [SVProgressHUD showWithStatus:@"Checking..."];
        [AmazonClientManager isAmazonAccount:emailField.text andDelegate:self];
    }
}

- (BOOL)textsFieldsValid
{
    return [self textFieldHasText:firstNameField]
        && [self textFieldHasText:lastNameField]
        && [self textFieldHasText:emailField]
        && [self textFieldHasText:shopNameField]
        && [self textFieldHasText:passwordFieldOne]
    && [self textFieldHasText:passwordFieldTwo];
}

- (BOOL)textFieldHasText:(UITextField *)textField
{
    return [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == firstNameField) {
        [lastNameField becomeFirstResponder];
    } else if (textField == lastNameField) {
        [emailField becomeFirstResponder];
    } else if (textField == emailField) {
        [shopNameField becomeFirstResponder];
    } else if (textField == shopNameField) {
        [passwordFieldOne becomeFirstResponder];
    } else if (textField == passwordFieldOne) {
        [passwordFieldTwo becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return true;
}

#pragma mark SubscriptionManagerDelegate
- (void) purchaseComplete:(NSError* _Nullable) error {
    //TODO manage error
    [SVProgressHUD dismiss];
    if(error) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failed to Activate Account"
                                                                                 message:error.description
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];
        [alertController addAction:OKAction];
        [self presentViewController:alertController animated:true completion:nil];
    }
    if([AmazonClientManager verifyLoggedIn])
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    return;
}

- (void) productsReturned:(NSArray* _Nullable)products {
    [SVProgressHUD dismiss];
    if( [products count] == 0 ) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"In-App Purchase Didn't Initialize"
                                                                                 message:@"An Error Occured, Unable to Create An Account Right Now"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];
        [alertController addAction:OKAction];
        [self presentViewController:alertController animated:true completion:nil];
    } else {
        
    }
}

#pragma mark LoginDelegate
- (void)amazonCheckResult:(BOOL)isAmazonAccount accountExists:(BOOL)exists {
    [SVProgressHUD dismiss];
    if(exists) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Account Exists"
                                                                                 message:@"An account with this email address already exists"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];
        [alertController addAction:OKAction];
        [self presentViewController:alertController animated:true completion:nil];
    } else {
        firstNameField.hidden = NO;
        lastNameField.hidden = NO;
        shopNameField.hidden = NO;
        passwordFieldOne.hidden = NO;
        passwordFieldTwo.hidden = NO;
        createButton.hidden = NO;
    }
}

- (void)onUserSignedIn {
    NSLog(@"Log in Successful, calling apple for subscription purchase");
    SubcriptionManager* manager = [SubcriptionManager sharedManager];
    [manager purchaseNewSubscription:[manager.products objectAtIndex:0]];
}

@end
