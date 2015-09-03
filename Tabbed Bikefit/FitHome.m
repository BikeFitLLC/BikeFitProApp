//
//  FitHome.m
//  bikefit
//
//  Created by Alfonso Lopez on 8/31/15.
//  Copyright (c) 2015 Alfonso Lopez. All rights reserved.
//

#import "FitHome.h"

@interface FitHome ()
{
    UIButton *athleteInfoButton;
    UIButton *bikeFitButton;
    UIButton *measurementButton;
}

@end

@implementation FitHome

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat buttonHeight = self.view.frame.size.height * .2;
    CGFloat buttonWidth = buttonHeight * 2;
    self.view.backgroundColor = [UIColor colorWithRed:0x7/255.0 green:0x31/255.0 blue:0x54/255.0 alpha:1.0];
    
    bikeFitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bikeFitButton.frame = CGRectMake(0,
                                         0,
                                         buttonWidth,
                                         buttonHeight);
    bikeFitButton.center = self.view.center;
    [bikeFitButton setImage:[UIImage imageNamed:@"Fitting-1x.png" ] forState:UIControlStateNormal];
    [bikeFitButton addTarget:self action:@selector(segueToBikeFit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bikeFitButton];
    
    athleteInfoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    athleteInfoButton.frame = CGRectMake(bikeFitButton.frame.origin.x,
                                         bikeFitButton.frame.origin.y - buttonHeight,
                                         buttonWidth,
                                         buttonHeight);
    [athleteInfoButton setImage:[UIImage imageNamed:@"Basic-Info-1x.png" ] forState:UIControlStateNormal];
    [athleteInfoButton addTarget:self action:@selector(segueToAthleteInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:athleteInfoButton];
    
    measurementButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    measurementButton.frame = CGRectMake(bikeFitButton.frame.origin.x,
                                         bikeFitButton.frame.origin.y + buttonHeight,
                                         buttonWidth,
                                         buttonHeight);
    [measurementButton setImage:[UIImage imageNamed:@"Measurement-1x.png" ] forState:UIControlStateNormal];
    [measurementButton addTarget:self action:@selector(segueToMeasurements:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:measurementButton];

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
