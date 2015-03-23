//
//  VarusNoteViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 2/24/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

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
    
    barYPosition = self.view.frame.size.height *.8;
    startPointLocation = CGPointMake(0, barYPosition);
    [(VarusDrawingView *)previewImage setStartPointLocation:startPointLocation];
    [(VarusDrawingView *)previewImage setBarYPosition:barYPosition];
    
    //Add images for dragbar
    upDownImageView =[[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   self.view.frame.size.width *.1,
                                                                   self.view.frame.size.width * .2)];
    upDownImageView.image=[UIImage imageNamed:@"up_down_arrows.png"];
    [self.view addSubview:upDownImageView];
    
    endPointLocation = CGPointMake(self.view.frame.size.height * .7, barYPosition);
    [(VarusDrawingView *)previewImage setEndPointLocation:endPointLocation];
    rotateArrowsImageView =[[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         self.view.frame.size.width *.1,
                                                                         self.view.frame.size.width * .2)];
    rotateArrowsImageView.image=[UIImage imageNamed:@"curved_arrows.png"];
    [self.view addSubview:rotateArrowsImageView];
    
    ffmdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  self.view.frame.size.width *.1,
                                                                  self.view.frame.size.width * .2)];
    ffmdImageView.image = [UIImage imageNamed:@"FFMD_Dial_only-200.png"];
    ffmdImageView.layer.anchorPoint = CGPointMake(0.5, 0.15);
    [self.view addSubview:ffmdImageView];

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

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (void) viewDidAppear:(BOOL)animated
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
            
            endPointLocation = CGPointMake(768,(oldEndPointLocation.y + translation.y));
            [(VarusDrawingView *)previewImage setEndPointLocation:endPointLocation];
        }
        NSLog(@"Moving drag box");
        
    }
    //othwerise, move the endpoint of the angle line
    else if(CGRectContainsPoint([rotateArrowsImageView frame], location))
    {
        startPointLocation = CGPointMake(0, startPointLocation.y + (endPointLocation.y - location.y));
        [(VarusDrawingView *)previewImage setStartPointLocation:startPointLocation];
        
        endPointLocation = CGPointMake(768, location.y);
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
    if((wholeAngle < 0 && ![bikeInfo leftNotesSelected]) || (wholeAngle >= 0 && [bikeInfo leftNotesSelected]))
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
    [note setPath:[previewImage overlayPath]];
    
    [self.bikeInfo addNote:note];
     
    [self.navigationController popToRootViewControllerAnimated:YES];
}



@end
