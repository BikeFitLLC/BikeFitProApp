//
//  CreateAccountViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 11/4/15.
//  Copyright © 2015 Alfonso Lopez. All rights reserved.
//

#import "CreateAccountViewController.h"

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
    self.view.backgroundColor = [UIColor colorWithRed:0x7/255.0 green:0x31/255.0 blue:0x54/255.0 alpha:1.0];

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
    [self.view addSubview:firstNameField];

    lastNameField = [[UITextField alloc] initWithFrame:CGRectMake(margin,
                                                               CGRectGetMaxY(firstNameField.frame) + margin,
                                                               width - (margin * 2),
                                                               fieldHeight)];
    lastNameField.placeholder = @"Last Name";
    [self applyTextFieldDefaults:lastNameField];
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
    [self.view addSubview:passwordFieldTwo];
    
    createButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    createButton.frame = CGRectMake(0,
                                    CGRectGetMaxY(passwordFieldTwo.frame) + (margin * 2),
                                    CGRectGetWidth(self.view.frame),
                                    fieldHeight);
    createButton.backgroundColor = [UIColor colorWithRed:0x7/255.0 green:0x45/255.0 blue:0x54/255.0 alpha:1.0];
    createButton.enabled = NO;
    [createButton setTitle:@"Create Account" forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(createAccount:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createButton];


    // Do any additional setup after loading the view.
    
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
    [[AmazonClientManager credProvider] createNewAccountWithEmail:emailField.text
                                                         password:passwordFieldOne.text
                                                         shopName:shopNameField.text
                                                        firstName:firstNameField.text
                                                         lastName:lastNameField.text];
    [self.navigationController popViewControllerAnimated:YES];
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

@end
