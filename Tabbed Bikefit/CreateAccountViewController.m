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

    emailField = [[UITextField alloc] initWithFrame:CGRectMake(margin,
                                                               bottomOfNavBar + margin,
                                                               width - (margin * 2),
                                                               fieldHeight)];
    emailField.borderStyle = UITextBorderStyleRoundedRect;
    emailField.backgroundColor = [UIColor whiteColor];
    emailField.font = [UIFont systemFontOfSize:15];
    emailField.placeholder = @"Email";
    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    emailField.returnKeyType = UIReturnKeyNext;
    emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [emailField setDelegate:self];
    [self.view addSubview:emailField];
    
    shopNameField = [[UITextField alloc] initWithFrame:CGRectMake(margin,
                                                                  CGRectGetMaxY(emailField.frame) + margin,
                                                                  width - (margin * 2),
                                                                  fieldHeight)];
    shopNameField.borderStyle = UITextBorderStyleRoundedRect;
    shopNameField.backgroundColor = [UIColor whiteColor];
    shopNameField.font = [UIFont systemFontOfSize:15];
    shopNameField.placeholder = @"Shop Name";
    shopNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    shopNameField.keyboardType = UIKeyboardTypeDefault;
    shopNameField.returnKeyType = UIReturnKeyNext;
    shopNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    shopNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [shopNameField setDelegate:self];
    [self.view addSubview:shopNameField];
    
    passwordFieldOne = [[UITextField alloc] initWithFrame:CGRectMake(margin,
                                                                     CGRectGetMaxY(shopNameField.frame) + margin,
                                                                     width - (margin * 2),
                                                                     fieldHeight)];
    passwordFieldOne.borderStyle = UITextBorderStyleRoundedRect;
    passwordFieldOne.backgroundColor = [UIColor whiteColor];
    passwordFieldOne.font = [UIFont systemFontOfSize:15];
    passwordFieldOne.placeholder = @"Password";
    passwordFieldOne.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordFieldOne.keyboardType = UIKeyboardTypeDefault;
    passwordFieldOne.returnKeyType = UIReturnKeyNext;
    passwordFieldOne.secureTextEntry = TRUE;
    passwordFieldOne.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordFieldOne.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [passwordFieldOne setDelegate:self];
    [passwordFieldOne addTarget:self action:@selector(textFieldDidEndEditing:)
        forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:passwordFieldOne];
    
    passwordFieldTwo = [[UITextField alloc] initWithFrame:CGRectMake(margin,
                                                                     CGRectGetMaxY(passwordFieldOne.frame) + margin,
                                                                     width - (margin * 2),
                                                                     fieldHeight)];
    passwordFieldTwo.secureTextEntry = YES;
    passwordFieldTwo.borderStyle = UITextBorderStyleRoundedRect;
    passwordFieldTwo.backgroundColor = [UIColor whiteColor];
    passwordFieldTwo.font = [UIFont systemFontOfSize:15];
    passwordFieldTwo.placeholder = @"Password";
    passwordFieldTwo.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordFieldTwo.keyboardType = UIKeyboardTypeDefault;
    passwordFieldTwo.returnKeyType = UIReturnKeyDone;
    passwordFieldTwo.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordFieldTwo.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [passwordFieldTwo setDelegate:self];
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

-(void)createAccount:(id)sender
{
    [[AmazonClientManager credProvider] createNewAccountWithEmail:emailField.text andPassword:passwordFieldOne.text andName:shopNameField.text];
    [self.navigationController popViewControllerAnimated:YES];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == emailField) {
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
