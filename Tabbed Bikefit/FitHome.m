//
//  FitHome.m
//  bikefit
//
//  Created by Alfonso Lopez on 8/31/15.
//  Copyright (c) 2015 Alfonso Lopez. All rights reserved.
//

#import "FitHome.h"
#import "BikefitConstants.h"

@interface FitHome ()
{
    UIButton *athleteInfoButton;
    UIButton *bikeFitButton;
    UIButton *measurementButton;
    UIButton *emailFitButton;
    MFMailComposeViewController* emailController;
}

@end

@implementation FitHome

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat buttonHeight = self.view.frame.size.height * .2;
    CGFloat buttonWidth = buttonHeight * 2.5;
    self.view.backgroundColor = [UIColor colorWithRed:0x7/255.0 green:0x31/255.0 blue:0x54/255.0 alpha:1.0];
    
    
    CGRect namelabelframe = CGRectMake(0,
                                      self.view.frame.size.height * .04,
                                      self.view.frame.size.width,
                                      self.view.frame.size.width * .1);

    UILabel *nameLabel = [[UILabel alloc] initWithFrame:namelabelframe];
    nameLabel.backgroundColor = [UIColor colorWithRed:0x29/255.0 green:0x65/255.0 blue:0x135/255.0 alpha:1.0];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.text = [NSString stringWithFormat:@"%@ %@", [AthletePropertyModel getProperty:AWS_FIT_ATTRIBUTE_FIRSTNAME],
                      [AthletePropertyModel getProperty:AWS_FIT_ATTRIBUTE_LASTNAME]];
    [self.view addSubview:nameLabel];
    
    bikeFitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bikeFitButton.frame = CGRectMake(self.view.center.x - buttonWidth * .5,
                                         self.view.center.y - buttonHeight,
                                         buttonWidth,
                                         buttonHeight);
    [bikeFitButton setImage:[UIImage imageNamed:@"Fitting" ] forState:UIControlStateNormal];
    [bikeFitButton addTarget:self action:@selector(segueToBikeFit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bikeFitButton];
    
    athleteInfoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    athleteInfoButton.frame = CGRectMake(bikeFitButton.frame.origin.x,
                                         bikeFitButton.frame.origin.y - buttonHeight,
                                         buttonWidth,
                                         buttonHeight);
    [athleteInfoButton setImage:[UIImage imageNamed:@"Basic-Info" ] forState:UIControlStateNormal];
    [athleteInfoButton addTarget:self action:@selector(segueToAthleteInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:athleteInfoButton];
    
    measurementButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    measurementButton.frame = CGRectMake(bikeFitButton.frame.origin.x,
                                         bikeFitButton.frame.origin.y + buttonHeight,
                                         buttonWidth,
                                         buttonHeight);
    [measurementButton setImage:[UIImage imageNamed:@"Measurement" ] forState:UIControlStateNormal];
    [measurementButton addTarget:self action:@selector(segueToMeasurements:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:measurementButton];
    
    emailFitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    emailFitButton.frame = CGRectMake(measurementButton.frame.origin.x,
                                         measurementButton.frame.origin.y + buttonHeight,
                                         buttonWidth,
                                         buttonHeight);
    [emailFitButton setImage:[UIImage imageNamed:@"Email-Fit" ] forState:UIControlStateNormal];
    [emailFitButton addTarget:self action:@selector(emailFit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:emailFitButton];

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
