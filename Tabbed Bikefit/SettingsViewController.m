//
//  SettingsViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 4/23/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "AMZNAuthorizeUserDelegate.h"

#import "SettingsViewController.h"
#import "AthletePropertyModel.h"
#import "BikefitConstants.h"
#import "AmazonClientManager.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) saveSettings
{
    //[[NSUserDefaults standardUserDefaults] setObject:fitterKeyField.text forKey:USER_DEFAULTS_FITTER_KEY_KEY];
    [[AmazonClientManager credProvider] refresh];
    
    [self.navigationController popViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
