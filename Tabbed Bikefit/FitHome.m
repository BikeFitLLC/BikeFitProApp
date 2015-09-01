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
}

@end

@implementation FitHome

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat buttonwidth = self.view.frame.size.width *.5;
    self.view.backgroundColor = [UIColor colorWithRed:0x7/255.0 green:0x31/255.0 blue:0x54/255.0 alpha:1.0];
    
    athleteInfoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    athleteInfoButton.frame = CGRectMake(0,
                                     self.view.frame.size.height *.5,
                                     buttonwidth,
                                     buttonwidth);
    [athleteInfoButton setImage:[UIImage imageNamed:@"Clients-1x.png" ] forState:UIControlStateNormal];
    [athleteInfoButton addTarget:self action:@selector(segueToAthleteInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:athleteInfoButton];

}

-(void)segueToAthleteInfo:(id)sender
{
    [self performSegueWithIdentifier:@"showathleteinfo" sender:sender];
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
