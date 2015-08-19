//
//  SaddleTiltNoteViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 5/11/15.
//  Copyright (c) 2015 Alfonso Lopez. All rights reserved.
//

#import "SaddleTiltNoteViewController.h"
#import "SaddleTiltView.h"
#import "AthletePropertyModel.h"
#import <CoreMotion/CoreMotion.h>

@interface SaddleTiltNoteViewController ()
{
    NSOperationQueue *deviceQueue;
    CMMotionManager *motionManager;
    CGFloat tiltAngle;
    
}

@end

@implementation SaddleTiltNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    saveButton.frame = CGRectMake(0,
                                  self.view.frame.size.height - self.view.frame.size.height * .1,
                                  self.view.frame.size.width,
                                  self.view.frame.size.height * .1);
    
    saveButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
    saveButton.backgroundColor = [UIColor blackColor];
    [saveButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setHidden:NO];
    [saveButton addTarget:self action:@selector(saveTiltAngle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];

    tilteAngleLabel = [[UILabel alloc] init];
    tilteAngleLabel.frame = CGRectMake(0,0,
                                       self.view.frame.size.width,
                                       self.view.frame.size.width/2);
    tilteAngleLabel.center = self.view.center;
    tilteAngleLabel.font = [UIFont fontWithName:@"Helvetica" size:64];
    tilteAngleLabel.backgroundColor = [UIColor blackColor];
    tilteAngleLabel.alpha = .5;
    tilteAngleLabel.numberOfLines = 2;
    tilteAngleLabel.textColor = [UIColor yellowColor];
    tilteAngleLabel.textAlignment = NSTextAlignmentCenter;
    tilteAngleLabel.adjustsFontSizeToFitWidth = true;
    [self.view addSubview:tilteAngleLabel];
    
    tilteAngleLabel.text = @"TILT!";
    

    //
    // Setup motion structures
    //
    deviceQueue = [[NSOperationQueue alloc] init];
    motionManager = [[CMMotionManager alloc] init];
    
    CGFloat updateInterval = 1/600.0;
    CMAttitudeReferenceFrame frame = CMAttitudeReferenceFrameXArbitraryCorrectedZVertical;
    [motionManager setDeviceMotionUpdateInterval:updateInterval];
    [motionManager startDeviceMotionUpdatesUsingReferenceFrame:frame
                                                       toQueue:deviceQueue
                                                   withHandler:
     ^(CMDeviceMotion* motion, NSError* error){
         CGFloat r = sqrtf(motion.gravity.x*motion.gravity.x + motion.gravity.y*motion.gravity.y + motion.gravity.z*motion.gravity.z);
         CGFloat tiltForwardBackward = acosf(motion.gravity.z/r) * 180.0f / M_PI - 90.0f;
         tiltAngle = (90 - tiltForwardBackward);
     }];
    
    //
    //Setup timer to update the tilt label
    //
    [NSTimer scheduledTimerWithTimeInterval: 0.01 target: self
                                   selector: @selector(updateTilt:)
                                   userInfo: nil
                                    repeats: YES];
}

- (void) updateTilt:(NSTimer *) timer
{
    tilteAngleLabel.text = [NSString stringWithFormat:@"%.02f°", tiltAngle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveTiltAngle:(id)sender
{
    [AthletePropertyModel setProperty:@"SaddleTilt" value:[NSString stringWithFormat:@"%.2f°", tiltAngle]];
    [self dismissViewControllerAnimated:YES completion:nil];
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
