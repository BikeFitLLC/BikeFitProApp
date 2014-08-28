//
//  VarusViewerViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 7/7/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "VarusViewerViewController.h"

@interface VarusViewerViewController ()

@end

@implementation VarusViewerViewController
@synthesize varusAngle;

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
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    angleLable.font = [UIFont fontWithName:@"Helvetica" size:100.0];
    angleLable.text = [NSString stringWithFormat:@"%d", (int)(varusAngle*57.2957795)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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