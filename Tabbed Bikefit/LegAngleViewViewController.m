//
//  LegAngleViewViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 2/28/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "LegAngleViewViewController.h"

@interface LegAngleViewViewController ()

@end

@implementation LegAngleViewViewController

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
    labelText = @"Knee Angle";

    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end