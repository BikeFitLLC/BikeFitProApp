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
    
    emailField = [[UITextField alloc] initWithFrame:CGRectMake(0,300,400,50)];
    emailField.center = CGPointMake(self.view.center.x, self.view.center.y - 150);
    emailField.borderStyle = UITextBorderStyleRoundedRect;
    emailField.backgroundColor = [UIColor whiteColor];
    emailField.font = [UIFont systemFontOfSize:15];
    emailField.placeholder = @"Email";
    emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailField.keyboardType = UIKeyboardTypeDefault;
    emailField.returnKeyType = UIReturnKeyDone;
    emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [emailField setDelegate:self];
    [self.view addSubview:emailField];
    
    shopNameField = [[UITextField alloc] initWithFrame:CGRectMake(0,300,400,50)];
    shopNameField.center = CGPointMake(self.view.center.x, self.view.center.y - 50);
    shopNameField.borderStyle = UITextBorderStyleRoundedRect;
    shopNameField.backgroundColor = [UIColor whiteColor];
    shopNameField.font = [UIFont systemFontOfSize:15];
    shopNameField.placeholder = @"Shop Name";
    shopNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    shopNameField.keyboardType = UIKeyboardTypeDefault;
    shopNameField.returnKeyType = UIReturnKeyDone;
    shopNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    shopNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [shopNameField setDelegate:self];
    [self.view addSubview:shopNameField];
    
    passwordFieldOne = [[UITextField alloc] initWithFrame:CGRectMake(0,360,400,50)];
    passwordFieldOne.center = CGPointMake(self.view.center.x, self.view.center.y + 50);
    passwordFieldOne.borderStyle = UITextBorderStyleRoundedRect;
    passwordFieldOne.backgroundColor = [UIColor whiteColor];
    passwordFieldOne.font = [UIFont systemFontOfSize:15];
    passwordFieldOne.placeholder = @"Password";
    passwordFieldOne.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordFieldOne.keyboardType = UIKeyboardTypeDefault;
    passwordFieldOne.returnKeyType = UIReturnKeyDone;
    passwordFieldOne.secureTextEntry = TRUE;
    passwordFieldOne.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordFieldOne.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [passwordFieldOne setDelegate:self];
    [passwordFieldOne addTarget:self action:@selector(textFieldDidEndEditing:)
        forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:passwordFieldOne];
    
    passwordFieldTwo = [[UITextField alloc] initWithFrame:CGRectMake(0,360,400,50)];
    passwordFieldTwo.center = CGPointMake(self.view.center.x, self.view.center.y + 150);
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
    createButton.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.width * .1);
    createButton.backgroundColor = [UIColor colorWithRed:0x7/255.0 green:0x45/255.0 blue:0x54/255.0 alpha:1.0];
    createButton.center = CGPointMake(self.view.center.x, self.view.center.y + self.view.frame.size.height *.3);
    createButton.hidden = NO;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
