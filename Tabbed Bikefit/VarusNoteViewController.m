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
    angleLabel.font = [UIFont fontWithName:@"Helvetica" size:100.0];
    
    barYPosition = 820;
    startPointLocation = CGPointMake(300, barYPosition);
    [(VarusDrawingView *)previewImage setStartPointLocation:startPointLocation];
    [(VarusDrawingView *)previewImage setBarYPosition:barYPosition];
    
    endPointLocation = CGPointMake(400,600);
    [(VarusDrawingView *)previewImage setEndPointLocation:endPointLocation];

    
    //Add tap recognition to the view
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveVertex:)];
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 2;
    [panGesture setDelegate:self];

    [self.view addGestureRecognizer:tapGesture];
    [self.view addGestureRecognizer:panGesture];

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
    if(CGRectContainsPoint([(VarusDrawingView *)previewImage getBarDragRect], location))
    {
        if(sender.state == UIGestureRecognizerStateBegan)
        {
            oldStartPointLocation = startPointLocation;
        }
        if(sender.state == UIGestureRecognizerStateChanged)
        {
            CGPoint translation = [sender translationInView:[self view]];
            
            barYPosition = oldStartPointLocation.y + translation.y;
            [(VarusDrawingView *)previewImage setBarYPosition:barYPosition];
            startPointLocation.y = oldStartPointLocation.y + translation.y;
            startPointLocation.x = oldStartPointLocation.x + translation.x;
            [(VarusDrawingView *)previewImage setStartPointLocation:startPointLocation];
        }
        NSLog(@"Moving drag box");
        
    }
    //othwerise, move the endpoint of the angle line
    else if(location.y > endPointLocation.y - 50 && location.y < endPointLocation.y + 50 &&
       location.x > endPointLocation.x - 50 && location.x < endPointLocation.x + 50)
    {
        endPointLocation = location;
        [(VarusDrawingView *)previewImage setEndPointLocation:endPointLocation];
    }
    
    [self calculateAngle];
    [(VarusDrawingView *)previewImage setNeedsDisplay];


}

- (void) calculateAngle
{
    angle = atanf((barYPosition - endPointLocation.y)/(endPointLocation.x - startPointLocation.x));
    angleLabel.text = [NSString stringWithFormat:@"%d", (int)(angle*57.2957795)];
}

- (IBAction)saveAngle
{
    VarusNote *note = [[VarusNote alloc] init];

    [note setAngle:angle];
    [note setImage:UIImageJPEGRepresentation(photo,.1)];
    
    [self.bikeInfo addNote:note];
     
    [self.navigationController popToRootViewControllerAnimated:YES];
}



@end
