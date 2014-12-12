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
@synthesize kneeVertices;
@synthesize shoulderVertices;
@synthesize hipVertices;

@synthesize kneeAngle;
@synthesize shoulderAngle;
@synthesize hipAngle;

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
    kneeAngleLabel = [[UILabel alloc] init];
    CGFloat height = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    kneeAngleLabel.frame = CGRectMake(0,height,250,75);
    kneeAngleLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
    kneeAngleLabel.backgroundColor = [UIColor blackColor];
    kneeAngleLabel.alpha = .5;
    kneeAngleLabel.numberOfLines = 2;
    kneeAngleLabel.textColor = [UIColor yellowColor];
    [self.view addSubview:kneeAngleLabel];
    
    shoulderAngleLabel = [[UILabel alloc] init];
    shoulderAngleLabel.frame = CGRectMake(250,height,250,75);
    shoulderAngleLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
    shoulderAngleLabel.backgroundColor = [UIColor blackColor];
    shoulderAngleLabel.alpha = .5;
    shoulderAngleLabel.numberOfLines = 2;
    shoulderAngleLabel.textColor = [UIColor greenColor];
    [self.view addSubview:shoulderAngleLabel];
    
    hipAngleLabel = [[UILabel alloc] init];
    hipAngleLabel.frame = CGRectMake(500,height,250,75);
    hipAngleLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
    hipAngleLabel.backgroundColor = [UIColor blackColor];
    hipAngleLabel.alpha = .5;
    hipAngleLabel.numberOfLines = 2;
    hipAngleLabel.textColor = [UIColor blueColor];
    [self.view addSubview:hipAngleLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(kneeVertices)
    {
        [drawingView setDrawKneePath:YES];
        [drawingView setKneeVertices:kneeVertices];
        //set the label contents
        int intAngle = (int)(kneeAngle * 57.2957795);
        NSString *kneeButtonText = [NSString stringWithFormat:@"Knee Flexion %d°\nKnee Angle %d° ",
                                    180-intAngle,
                                    intAngle];
        kneeAngleLabel.text = kneeButtonText;
    }
    if(hipVertices)
    {
        int intAngle = (int)(hipAngle * 57.2957795);
        NSString *hipLabelText = [NSString stringWithFormat:@"Hip Flexion %d°",intAngle];
        hipAngleLabel.text = hipLabelText;
        [drawingView setDrawHipPath:YES];
        [drawingView setHipVertices:hipVertices];
    }
    if(shoulderVertices)
    {
        int intAngle = (int)(shoulderAngle * 57.2957795);
        NSString *shoulderLabelText = [NSString stringWithFormat:@"Shoulder Flexion %d°",intAngle];
        shoulderAngleLabel.text = shoulderLabelText;
        [drawingView setDrawShoulderPath:YES];
        [drawingView setShoulderVertices:shoulderVertices];
    }
    
    
    [drawingView setNeedsDisplay];
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
