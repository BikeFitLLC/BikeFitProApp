//
//  AngleImageViewerViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 4/2/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "AngleImageViewerViewController.h"

@interface AngleImageViewerViewController ()

@end

@implementation AngleImageViewerViewController
@synthesize vertices;

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [drawingView setVertices:vertices];
    [drawingView calculateAngle];
    [drawingView drawAngle:[[drawingView.vertices objectAtIndex:0] CGPointValue]
                                               b:[[drawingView.vertices objectAtIndex:1] CGPointValue]
                                               c:[[drawingView.vertices objectAtIndex:2] CGPointValue]
                                            ];
    angleLabel.text = [NSString stringWithFormat:@"%d", (int)([drawingView angle] * 57.2957795)];
    angleLabel.font = [UIFont fontWithName:@"Helvetica" size:100.0];
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
