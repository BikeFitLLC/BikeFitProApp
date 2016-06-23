//
//  KneeViewController.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 9/28/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "KneeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AthletePropertyModel.h"
#import <CoreMotion/CoreMotion.h>

@interface KneeViewController ()
{
    UIImageView *lazerDragCircle;
    NSOperationQueue *deviceQueue;
    CMMotionManager *motionManager;
    CGAffineTransform gravityTransform;
    CGFloat angle;
    CGPoint oldStartPointLocation;
    CGPoint oldEndPointLocation;
}

@end

@implementation KneeViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [saveButton addTarget:self action:@selector(keepLine:) forControlEvents:UIControlEventTouchUpInside];
    
    previewImage = [[KneeDrawingView alloc] initWithFrame:self.view.frame];
    previewImage.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:previewImage aboveSubview:cameraPreviewView];
    [self.view bringSubviewToFront:videoToolBarView];
    [self.view bringSubviewToFront:recordButton];
    [self.view bringSubviewToFront:saveButton];
    [self.view bringSubviewToFront:reverseCameraButton];
    
    //////////Setup motion structures//////////////////
    deviceQueue = [[NSOperationQueue alloc] init];
    motionManager = [[CMMotionManager alloc] init];
    
    CGFloat updateInterval = 1/300.0;
    CMAttitudeReferenceFrame frame = CMAttitudeReferenceFrameXArbitraryCorrectedZVertical;
    [motionManager setDeviceMotionUpdateInterval:updateInterval];
    [motionManager startDeviceMotionUpdatesUsingReferenceFrame:frame
                                                       toQueue:deviceQueue
                                                   withHandler:
     ^(CMDeviceMotion* motion, NSError* error)
    {
        KneeDrawingView *kneeDrawingView = (KneeDrawingView *)previewImage;
        angle =  atan2( motion.gravity.x, motion.gravity.y );
        kneeDrawingView.endPoint = [self calculatePointAlongLazerVectorForLength:1500 andStartPoint:[kneeDrawingView startPoint]];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    if(videoUrl)
    {
        [self stopCapturing];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)moveLazerLeft:(id)sender
{
    UIPanGestureRecognizer *recog = (UIPanGestureRecognizer *)sender;
    KneeDrawingView *kneeView = (KneeDrawingView *)previewImage;

    if(recog.state == UIGestureRecognizerStateBegan)
    {
        if(CGRectContainsPoint(lazerDragCircle.frame,[recog locationInView:self.view]))
        {
            oldStartPointLocation = kneeView.startPoint;
            oldEndPointLocation = kneeView.endPoint;
            
        }
        else
        {
            if(kneeView.drawingEnabled)
            {
                if(!kneeView.path)
                {
                    kneeView.path = [[UIBezierPath alloc]init];
                }
                
                [kneeView.path removeAllPoints];
                [kneeView.path moveToPoint:[recog locationInView:self.view]];
            }
            return;
            
        }
    }
    if(recog.state == UIGestureRecognizerStateChanged)
    {
        if(CGRectContainsPoint(lazerDragCircle.frame,[recog locationInView:self.view]))
        {   
            CGPoint translation = [sender translationInView:[self view]];
            
            CGPoint startPointLocation = CGPointMake(oldStartPointLocation.x + translation.x, 0);
            kneeView.startPoint = startPointLocation;
            
            CGPoint endPointLocation = CGPointMake(oldEndPointLocation.x + translation.x, oldEndPointLocation.y);
            kneeView.endPoint = endPointLocation;
        }
        else
        {
            if(kneeView.drawingEnabled)
            {
                [kneeView.path addLineToPoint:[recog locationInView:self.view]];
            }
        }
        
    }

        lazerDragCircle.center = [self calculatePointAlongLazerVectorForLength:self.view.frame.size.height * .2 andStartPoint:kneeView.startPoint];
        [kneeView setNeedsDisplay];
    
}

- (IBAction)keepLine:(id)sender
{
    KneeViewNote *note = [[KneeViewNote alloc] init];
    
    [note setPath:[(KneeDrawingView *)previewImage path]];
    [note setLazerPath:[(KneeDrawingView *)previewImage lazerPath]];
    [note setVideoUrl:videoUrl];
    
    [bikeInfo addNote:note];
    [self.navigationController popToViewController:bikeInfo animated:YES];
}
- (void) stopCapturing
{
    [super stopCapturing];
    [motionManager stopDeviceMotionUpdates];
    [(KneeDrawingView *)previewImage stopLazer];
    [nextImageButton setHidden:NO];
    [previousImageButton setHidden:NO];
    [saveButton setEnabled:YES];
    [lazerLeftButton setHidden:NO];
    [lazerRightButton setHidden:NO];
    [recordButton setHidden:YES];
    [playButton setHidden:NO];
    
    lazerDragCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RecordIcon"]];
    lazerDragCircle.center = [self calculatePointAlongLazerVectorForLength:self.view.frame.size.height * .2 andStartPoint:[(KneeDrawingView *)previewImage startPoint]];
    UIPanGestureRecognizer *panRecog = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveLazerLeft:)];
    [panRecog setMinimumNumberOfTouches:1];
    [panRecog setMaximumNumberOfTouches:1];
    [panRecog setDelegate:self];
    [self.view addGestureRecognizer:panRecog];
    [self.view addSubview:lazerDragCircle];
    
}

- (CGPoint) calculatePointAlongLazerVectorForLength:(int)length andStartPoint:(CGPoint) startPoint
{
    CGPoint newPoint;
    newPoint.x = (cosf(angle - 1.57079633) * length) + startPoint.x;
    newPoint.y = sinf(angle - 1.57079633) * length;
    return newPoint;
}
@end
