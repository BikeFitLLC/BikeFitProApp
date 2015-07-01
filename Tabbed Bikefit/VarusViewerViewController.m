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
    
    imageView = [[UIImageView alloc] initWithImage:self.image];
    imageView.frame = self.view.frame;
    imageView.center = self.view.center;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
    
    drawingView = [[DrawingView alloc] initWithFrame:self.view.frame];
    drawingView.backgroundColor = [UIColor clearColor];
    drawingView.center = self.view.center;
    [self.view addSubview:drawingView];
    
    angleLabel = [[UILabel alloc] init];
    angleLabel.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height,
                                  self.view.frame.size.width *.3,
                                  self.view.frame.size.height *.1);
    
    angleLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
    angleLabel.backgroundColor = [UIColor blackColor];
    angleLabel.textColor = [UIColor yellowColor];
    angleLabel.alpha = .5;
    angleLabel.textAlignment = NSTextAlignmentCenter;
    angleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:angleLabel];
}

- (void) viewWillAppear:(BOOL)animated
{
    drawingView.overlayPath = self.overlayPath;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    angleLabel.text = [NSString stringWithFormat:@"%d°", (int)(varusAngle*57.2957795)];
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
