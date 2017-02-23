//
//  VarusNoteViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 2/24/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "Util.h"
#import "VarusNoteViewController.h"
#import "VarusNote.h"

@interface VarusNoteViewController ()
{
    CGPoint endPointLocation;
    CGPoint startPointLocation;
    CGPoint oldStartPointLocation; //use to save the old position during pan gestures
    CGPoint oldEndPointLocation;
    CGFloat barYPosition;
    CGFloat angle;
    
    UIImageView *suggestedWedgesOne;
    UIImageView *suggestedWedgesTwo;
    UIImageView *suggestedWedgesThree;

    UIView *_overlayView;
}

@end

@implementation VarusNoteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    angleLabel = [[UILabel alloc] init];
    angleLabel.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height,
                                  self.view.frame.size.width *.3,
                                  self.view.frame.size.height *.1);
    
    angleLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
    angleLabel.backgroundColor = [UIColor blackColor];
    angleLabel.textColor = [UIColor yellowColor];
    angleLabel.alpha = .5;
    angleLabel.numberOfLines = 2;
    angleLabel.adjustsFontSizeToFitWidth = YES;
    angleLabel.text = @"Angle";
    [self.view addSubview:angleLabel];
    
    [recordButton setHidden:TRUE];
    leftLegImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2_heels_left.png"]];
    leftLegImageView.alpha = .2;
    leftLegImageView.frame = self.view.frame;
    [self.view addSubview:leftLegImageView];

    rightLegImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2_heel_right.png"]];
    rightLegImageView.alpha = .2;
    rightLegImageView.frame = self.view.frame;
    [self.view addSubview:rightLegImageView];
    
    
    
    angleLabel.font = [UIFont fontWithName:@"Helvetica" size:100.0];
    
    barYPosition = self.view.frame.size.height * .7;
    startPointLocation = CGPointMake(0, barYPosition);
    
    previewImage =[[VarusDrawingView alloc] initWithFrame:self.view.frame];
    [(VarusDrawingView *)previewImage setBackgroundColor:[UIColor clearColor]];
    [(VarusDrawingView *)previewImage setStartPointLocation:startPointLocation];
    [(VarusDrawingView *)previewImage setBarYPosition:barYPosition];
    [self.view addSubview:previewImage];
    
    takePhotoButton.hidden = false;

    [self.view bringSubviewToFront:videoToolBarView];

    //
    //Create Image View for Suggestions
    //
    if([bikeInfo leftNotesSelected])
    {
        suggestedWedgesOne = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_wedge_Left_varus.png"]];
        suggestedWedgesTwo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2_wedge_left_varus.png"]];
        suggestedWedgesThree = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"3_wedge_left_varus.png"]];
    }
    else
    {
        suggestedWedgesOne = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1_Wedge_Rght_Varus.png"]];
        suggestedWedgesTwo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2_Wedge_RGHT_varus.png"]];
        suggestedWedgesThree = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"3_Wedge_Rght_Varus.png"]];
    }
    
    CGRect frame = CGRectMake(self.view.frame.size.width * .05,
                              self.view.frame.size.height * .85,
                              self.view.frame.size.width *.3,
                              self.view.frame.size.width * .1);
    
    suggestedWedgesOne.frame = frame;
    suggestedWedgesTwo.frame = frame;
    suggestedWedgesThree.frame = frame;
    
    suggestedWedgesOne.hidden = YES;
    suggestedWedgesTwo.hidden = YES;
    suggestedWedgesThree.hidden = YES;
    
    [self.view addSubview:suggestedWedgesTwo];
    [self.view addSubview:suggestedWedgesOne];
    [self.view addSubview:suggestedWedgesThree];

    _overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    _overlayView.backgroundColor = [UIColor clearColor];
    _overlayView.userInteractionEnabled = false;
    [self.view addSubview:_overlayView];

    //Add images for dragbar
    upDownImageView =[[UIImageView alloc] initWithFrame:CGRectMake(250,
                                                                   0,
                                                                   self.view.frame.size.width *.1,
                                                                   self.view.frame.size.width * .2)];
    upDownImageView.image=[UIImage imageNamed:@"up_down_arrows.png"];
    [_overlayView addSubview:upDownImageView];
    
    rotateArrowsImageView =[[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         self.view.frame.size.width *.1,
                                                                         self.view.frame.size.width * .2)];
    rotateArrowsImageView.image=[UIImage imageNamed:@"curved_arrows.png"];
    [_overlayView addSubview:rotateArrowsImageView];
    
    ffmdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  self.view.frame.size.width *.3,
                                                                  self.view.frame.size.width *.3/1.74)];
    ffmdImageView.image = [UIImage imageNamed:@"FFMD_Dial_only-200.png"];
    ffmdImageView.layer.anchorPoint = CGPointMake(0.5, 0.15);
    ffmdImageView.hidden = true;
    [_overlayView addSubview:ffmdImageView];
    
    endPointLocation = CGPointMake(self.view.frame.size.width, barYPosition);
    [(VarusDrawingView *)previewImage setEndPointLocation:endPointLocation];

    //now that the dragbar images are added to the view, position them correctly
    [self updateArrowImages];
    
    //Add tap recognition to the view
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveVertex:)];
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 2;
    [panGesture setDelegate:self];

    //[self.view addGestureRecognizer:tapGesture];
    [self.view addGestureRecognizer:panGesture];
    
    [saveButton addTarget:self action:@selector(saveAngle) forControlEvents:UIControlEventTouchUpInside];

    [self.view bringSubviewToFront:takePhotoButton];
    [self.view bringSubviewToFront:saveButton];
    [self.view bringSubviewToFront:reverseCameraButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [Util setScreenLeftRightTitle:self leftSelected:[bikeInfo leftNotesSelected] key:@"ScreenTitle_FootTilt"];
    
    if( [bikeInfo leftNotesSelected])
    {
        [leftLegImageView setHidden:false];
        [rightLegImageView setHidden:true];
    }
    else
    {
        [leftLegImageView setHidden:true];
        [rightLegImageView setHidden:false];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


///////////////////////////////
//Gesture Handlers
////////////////////////////////
- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint location = [sender locationInView:[self view]];
        
        if(location.y > 800 && location.y < 840)
        {
            startPointLocation.x = location.x;
            [(VarusDrawingView *) previewImage setStartPointLocation:startPointLocation];
        }
        else
        {
            endPointLocation = location;
            [(VarusDrawingView *)previewImage setEndPointLocation:endPointLocation];
        }
        [self calculateAngle];
        [(VarusDrawingView *)previewImage setNeedsDisplay];
    }
}

- (void) moveVertex:(UIPanGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:[self view]];
  
    //if the pan gesture is taking place in the "drag box" move the drag box along with it
    if(CGRectContainsPoint([upDownImageView frame], location))
    {
        if(sender.state == UIGestureRecognizerStateBegan)
        {
            oldStartPointLocation = startPointLocation;
            oldEndPointLocation = endPointLocation;
            
        }
        if(sender.state == UIGestureRecognizerStateChanged)
        {
            CGPoint translation = [sender translationInView:[self view]];
            
            startPointLocation = CGPointMake(0, (oldStartPointLocation.y + translation.y));
            [(VarusDrawingView *)previewImage setStartPointLocation:startPointLocation];
            
            endPointLocation = CGPointMake(self.view.frame.size.width,(oldEndPointLocation.y + translation.y));
            [(VarusDrawingView *)previewImage setEndPointLocation:endPointLocation];
        }
        NSLog(@"Moving drag box");
        
    }
    //othwerise, move the endpoint of the angle line
    else if(CGRectContainsPoint([rotateArrowsImageView frame], location))
    {
        startPointLocation = CGPointMake(0, startPointLocation.y + (endPointLocation.y - location.y));
        [(VarusDrawingView *)previewImage setStartPointLocation:startPointLocation];
        
        endPointLocation = CGPointMake(self.view.frame.size.width, location.y);
        [(VarusDrawingView *)previewImage setEndPointLocation:endPointLocation];
        
        [self calculateAngle];
        
        [ffmdImageView.layer setTransform:CATransform3DMakeRotation(-angle, 0, 0, 1.0 )];
    }
    
    [self updateArrowImages];
    
    [(VarusDrawingView *)previewImage setNeedsDisplay];
}

//Updates thelocation of the arrow images (up-down and curved)
- (void) updateArrowImages
{
    CGFloat x = endPointLocation.x - startPointLocation.x;
    CGFloat hypotenuse = x/cosf(angle);
    
    CGFloat relativeEndpointY = sinf(angle) * fabsf(hypotenuse *.9);
    CGFloat relativeEndpointX = cosf(angle) * fabsf(hypotenuse *.9);
    NSLog(@"Created floats: %f - %f - For Angle: %f", relativeEndpointX, relativeEndpointY,angle);
    
    
    [rotateArrowsImageView setCenter:CGPointMake(relativeEndpointX+startPointLocation.x, startPointLocation.y - relativeEndpointY)];
    [rotateArrowsImageView.layer setTransform:CATransform3DMakeRotation(-angle, 0, 0, 1.0 )];
    NSLog(@"rotated curved arrows");
    upDownImageView.center = CGPointMake(startPointLocation.x+50, startPointLocation.y);
    NSLog(@"moved updown arrows");
    
    [ffmdImageView setCenter:CGPointMake(
                                         previewImage.bounds.size.width/2,
                                         (startPointLocation.y +endPointLocation.y)/2 + 31)];
}

- (void) calculateAngle
{
    angle = atanf((startPointLocation.y - endPointLocation.y)/(endPointLocation.x - startPointLocation.x));
    int wholeAngle = (int)(angle*57.2957795);
    int absoluteAngle = abs(wholeAngle);
    bool varus = ((wholeAngle < 0 && ![bikeInfo leftNotesSelected]) || (wholeAngle >= 0 && [bikeInfo leftNotesSelected]));
    if(absoluteAngle <= 4)
    {
        suggestedWedgesOne.hidden = YES;
        suggestedWedgesTwo.hidden = YES;
        suggestedWedgesThree.hidden = YES;
    }
    if(absoluteAngle > 4 && absoluteAngle <= 6)
    {
        suggestedWedgesOne.hidden = NO;
        suggestedWedgesTwo.hidden = YES;
        suggestedWedgesThree.hidden = YES;
    }
    if(absoluteAngle > 6 && absoluteAngle <= 12 && varus)
    {
        suggestedWedgesOne.hidden = YES;
        suggestedWedgesTwo.hidden = NO;
        suggestedWedgesThree.hidden = YES;
    }
    if(absoluteAngle > 12 && varus)
    {
        suggestedWedgesOne.hidden = YES;
        suggestedWedgesTwo.hidden = YES;
        suggestedWedgesThree.hidden = NO;
    }
    
    if(varus)
    {
       angleLabel.text = [NSString stringWithFormat:@"%d° Varus", abs(wholeAngle)];
    }
    else
    {
        angleLabel.text = [NSString stringWithFormat:@"%d Valgus°", abs(wholeAngle)];
    }
    
}

- (IBAction)saveAngle
{
    VarusNote *note = [[VarusNote alloc] init];
    [note setLeftFoot:[bikeInfo leftNotesSelected]];

    [note setAngle:angle];
    [note setImage:UIImageJPEGRepresentation(photo,.1)];
    [note setPath:[(VarusDrawingView *)previewImage overlayPath]];
    
    [self.bikeInfo addNote:note];
     
    [self.navigationController popToViewController:bikeInfo animated:YES];
}

- (void)photoCaptured
{
    dispatch_async(dispatch_get_main_queue(), ^{
        ffmdImageView.hidden = false;
    });
}


@end
