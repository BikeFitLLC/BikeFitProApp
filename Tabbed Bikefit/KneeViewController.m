//
//  KneeViewController.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 9/28/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "AthletePropertyModel.h"
#import "GUIKneeTouchInterceptorView.h"
#import "KneeViewController.h"
#import "Util.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

@interface KneeViewController () <GUIKneeTouchInterceptorViewDelegate>
{
    UIImageView *lazerDragCircle;
    NSOperationQueue *deviceQueue;
    CMMotionManager *motionManager;
    CGAffineTransform gravityTransform;
    CGFloat angle;
    CGPoint oldStartPointLocation;
    CGPoint oldEndPointLocation;
    GUIKneeTouchInterceptorView *_kneeInterceptionView;
    BOOL _hasCaptured;
    UITouch *_currentTouch;
    BOOL _dragging;
    CGPoint _touchStartPoint;
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
    _kneeInterceptionView = [[GUIKneeTouchInterceptorView alloc] initWithFrame:self.view.bounds];
    _kneeInterceptionView.delegate = self;
    [self.view insertSubview:previewImage aboveSubview:cameraPreviewView];
    [self.view insertSubview:_kneeInterceptionView aboveSubview:previewImage];
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
        float length = CGRectGetHeight(kneeDrawingView.bounds) - [kneeDrawingView startPoint].y;
        kneeDrawingView.endPoint = [self calculatePointAlongLazerVectorForLength:length
                                                                   andStartPoint:[kneeDrawingView startPoint]];
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
    
    [Util setScreenLeftRightTitle:self leftSelected:[self.bikeInfo leftNotesSelected] key:@"ScreenTitle_CleatMedialLateralStanceWidth"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)moveLazerLeft:(id)sender
{   
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
    lazerDragCircle.alpha = 0.3;
    [self.view addSubview:lazerDragCircle];
    _hasCaptured = true;
    
}

- (CGPoint) calculatePointAlongLazerVectorForLength:(int)length andStartPoint:(CGPoint) startPoint
{
    CGPoint newPoint;
    newPoint.x = (cosf(angle - M_PI_2) * length) + startPoint.x;
    newPoint.y = sinf(angle - M_PI_2) * length;
    return newPoint;
}

#pragma mark -  KneeTouchViewDelegate

- (void)kneeViewTouchesBegan:(NSSet *)touches
{
    KneeDrawingView *kneeView = (KneeDrawingView *)previewImage;
    if (_hasCaptured) {
        if (!_currentTouch) {
            _currentTouch = touches.anyObject;
            _touchStartPoint = [_currentTouch locationInView:self.view];
            if (CGRectContainsPoint(lazerDragCircle.frame, _touchStartPoint)) {
                _dragging = true;
                oldStartPointLocation = kneeView.startPoint;
                oldEndPointLocation = kneeView.endPoint;
            } else {
                if(kneeView.drawingEnabled)
                {
                    if(!kneeView.path)
                    {
                        kneeView.path = [[UIBezierPath alloc]init];
                    }

                    [kneeView.path removeAllPoints];
                    [kneeView.path moveToPoint:_touchStartPoint];
                }
            }
        }
    }
}

- (void)kneeViewTouchesMoved:(NSSet *)touches
{
    KneeDrawingView *kneeView = (KneeDrawingView *)previewImage;
    if (_hasCaptured && _currentTouch) {
        CGPoint currentPoint = [_currentTouch locationInView:self.view];
        if(_dragging)
        {
            CGPoint translation = CGPointMake(currentPoint.x - _touchStartPoint.x, 0);

            CGPoint startPointLocation = CGPointMake(oldStartPointLocation.x + translation.x, 0);
            kneeView.startPoint = startPointLocation;

            CGPoint endPointLocation = CGPointMake(oldEndPointLocation.x + translation.x, oldEndPointLocation.y);
            kneeView.endPoint = endPointLocation;
            lazerDragCircle.center = [self calculatePointAlongLazerVectorForLength:[self calculateYForLazerDragCircle:currentPoint]
                                                                     andStartPoint:kneeView.startPoint];

        }
        else
        {
            if(kneeView.drawingEnabled)
            {
                [kneeView.path addLineToPoint:[_currentTouch locationInView:self.view]];
            }
        }
    }

}

- (float)calculateYForLazerDragCircle:(CGPoint)point
{
    float y = point.y;
    float top = CGRectGetMaxY(self.navigationController.navigationBar.frame) + (CGRectGetHeight(lazerDragCircle.bounds) * 0.5);
    float bottom = CGRectGetMinY(videoToolBarView.frame) - (CGRectGetHeight(lazerDragCircle.bounds) * 0.5);

    return MAX(top, MIN(bottom, y));
}

- (void)kneeViewTouchesEnded:(NSSet *)touches
{
    if (_hasCaptured) {
        _currentTouch = nil;
        _dragging = false;
    }
}

@end
