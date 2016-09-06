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
    UIImageView *saddleImage;
    UILabel *upArrow;
    UILabel *downArrow;
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
    
    CGFloat navHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    CGFloat imageHeight = (CGRectGetMinY(tilteAngleLabel.frame) - navHeight) * 0.75;
    CGFloat imageY = navHeight + (imageHeight / 6);
    saddleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"saddle_silhouette_60.png"]];
    saddleImage.frame = CGRectMake(0,
                                   imageY,
                                   self.view.frame.size.width,
                                   imageHeight);
    saddleImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:saddleImage];
    
    float arrowEdge = CGRectGetHeight(saddleImage.frame) * 0.5;
    upArrow = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(saddleImage.frame), arrowEdge, arrowEdge)];
    upArrow.text = @"▲";
    upArrow.textAlignment = NSTextAlignmentCenter;
    upArrow.font = [UIFont systemFontOfSize:arrowEdge];
    [self.view addSubview:upArrow];

    downArrow = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(upArrow.frame), arrowEdge, arrowEdge)];
    downArrow.text = @"▼";
    downArrow.textAlignment = NSTextAlignmentCenter;
    downArrow.font = [UIFont systemFontOfSize:arrowEdge];
    [self.view addSubview:downArrow];

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
         [self motionUpdated:motion];
     }];
    
    //
    //Setup timer to update the tilt label
    //
    [NSTimer scheduledTimerWithTimeInterval: 0.01 target: self
                                   selector: @selector(updateTilt:)
                                   userInfo: nil
                                    repeats: YES];
}

- (void)motionUpdated:(CMDeviceMotion *)motion {
    CGFloat r = sqrtf(motion.gravity.y * motion.gravity.y + motion.gravity.z * motion.gravity.z);
    CGFloat tiltForwardBackward = acosf(motion.gravity.z/r) * 180.0f / M_PI - 90.0f;
    tiltAngle = (90 - tiltForwardBackward) * (motion.gravity.y < 0 ? -1 : 1);
}

- (void) updateTilt:(NSTimer *) timer
{
    float displayAngle = roundf(tiltAngle * 10) * 0.1;
    tilteAngleLabel.text = [NSString stringWithFormat:@"%.01f°", displayAngle];
    CGAffineTransform t = CGAffineTransformMakeRotation(displayAngle * M_PI / 180);
    saddleImage.layer.transform = CATransform3DMakeAffineTransform(t);
    upArrow.alpha = displayAngle > 0 ? 1 : 0.25;
    downArrow.alpha = displayAngle < 0 ? 1 : 0.25;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveTiltAngle:(id)sender
{
    [AthletePropertyModel setProperty:@"SaddleTilt" value:[NSString stringWithFormat:@"%.2f°", tiltAngle]];
    [self.navigationController popViewControllerAnimated:YES];
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
