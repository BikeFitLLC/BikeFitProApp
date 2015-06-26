//
//  LegAngleViewController.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 10/1/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "GoniometerViewController.h"
#import "AthletePropertyModel.h"
#import <QuartzCore/QuartzCore.h>
#import <math.h>

@interface GoniometerViewController (){
    int vertexIndex;
    int indexOfMovingPoint;
    NSMutableArray *movingVerticeArray;
    CGFloat xOffset;
    CGFloat yOffset;
}
@end

@implementation GoniometerViewController
@synthesize propertyName;
@synthesize labelText;

#define dragRadius 50

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
    [saveButton addTarget:self action:@selector(saveAngle) forControlEvents:UIControlEventTouchUpInside];
    
    previewImage = [[LegAngleImageView alloc] initWithFrame:self.view.frame];
    previewImage.backgroundColor = [UIColor clearColor];
    [self.view addSubview:previewImage];
    
    [self.view bringSubviewToFront:recordButton];
    [self.view bringSubviewToFront:saveButton];
    [self.view bringSubviewToFront:previousImageButton];
    [self.view bringSubviewToFront:nextImageButton];
    
    
    CGFloat oneThirdViewWidth = self.view.frame.size.width/3;
    
    kneeAngleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGFloat height = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    kneeAngleButton.frame = CGRectMake(0,
                                       height,
                                       oneThirdViewWidth,
                                       oneThirdViewWidth * .3);
    kneeAngleButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
    kneeAngleButton.backgroundColor = [UIColor blackColor];
    kneeAngleButton.alpha = .5;
    kneeAngleButton.titleLabel.numberOfLines = 2;
    kneeAngleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [kneeAngleButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [kneeAngleButton setTitle:@"Tap to add\nleg angle finder" forState:UIControlStateNormal];
    kneeAngleButton.hidden = YES;
    [kneeAngleButton addTarget:self action:@selector(enableAngle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:kneeAngleButton];
    
    shoulderAngleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    shoulderAngleButton.frame = CGRectMake(oneThirdViewWidth,
                                           height,
                                           oneThirdViewWidth,
                                           oneThirdViewWidth * .3);
    shoulderAngleButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
    shoulderAngleButton.backgroundColor = [UIColor blackColor];
    shoulderAngleButton.alpha = .5;
    shoulderAngleButton.titleLabel.numberOfLines = 2;
    shoulderAngleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [shoulderAngleButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [shoulderAngleButton setTitle:@"Tap to add\nshoulder angle finder" forState:UIControlStateNormal];
    shoulderAngleButton.hidden = YES;
    [shoulderAngleButton addTarget:self action:@selector(enableAngle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shoulderAngleButton];
    
    HipAngleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    HipAngleButton.frame = CGRectMake(2*oneThirdViewWidth,
                                      height,
                                      oneThirdViewWidth,
                                      oneThirdViewWidth * .3);
    HipAngleButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
    HipAngleButton.backgroundColor = [UIColor blackColor];
    HipAngleButton.alpha = .5;
    HipAngleButton.titleLabel.numberOfLines = 2;
    HipAngleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [HipAngleButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [HipAngleButton setTitle:@"Tap to add\nhip angle finder" forState:UIControlStateNormal];
    HipAngleButton.hidden = YES;
    [HipAngleButton addTarget:self action:@selector(enableAngle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:HipAngleButton];
    
    saveButton.center = CGPointMake(self.view.frame.size.width * .9, 175);
    
    vertexIndex = 0;
    indexOfMovingPoint = -1;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveVertex:)];
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 2;
    [panGesture setDelegate:self];

    [self.view addGestureRecognizer:panGesture];

}

- (void)enableAngle:(id)sender
{
    LegAngleImageView* imageView = (LegAngleImageView *)previewImage;
    bool originalState = false;
    
    if(sender == kneeAngleButton)
    {
        originalState = imageView.drawKneePath;
        [imageView setDrawKneePath:!originalState];
    }
    else if(sender == shoulderAngleButton)
    {
        originalState = imageView.drawShoulderPath;
        [imageView setDrawShoulderPath:!originalState];
    }
    else if(sender == HipAngleButton)
    {
        originalState = imageView.drawHipPath;
        [imageView setDrawHipPath:!originalState];
    }
    
    if(!originalState)
    {
        [sender setTitle:@"Drag Vertices\nto get angle" forState:UIControlStateNormal];
        
    }
    
    [imageView setNeedsDisplay];
}


/*
 * Determines if the pan gesture should begin based on whether or not the location
 * is close enough to one of the vertices
 * TODO: This and "move vertex" are duplicating some logic.  Rfactor?
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    LegAngleImageView* imageView = (LegAngleImageView*)previewImage;
    
    if(vertexIndex == 0 && [imageView.kneeVertices count] == 3)
    {
        CGPoint location = [gestureRecognizer locationInView:[self view]];
        if( [self proximityOfTwoPoints:location b:[[imageView.kneeVertices objectAtIndex:0] CGPointValue]] < dragRadius ||
           [self proximityOfTwoPoints:location b:[[imageView.kneeVertices objectAtIndex:1] CGPointValue]] < dragRadius ||
           [self proximityOfTwoPoints:location b:[[imageView.kneeVertices objectAtIndex:2] CGPointValue]] < dragRadius||
           [self proximityOfTwoPoints:location b:[[imageView.shoulderVertices objectAtIndex:0] CGPointValue]] < dragRadius ||
           [self proximityOfTwoPoints:location b:[[imageView.shoulderVertices objectAtIndex:1] CGPointValue]] < dragRadius ||
           [self proximityOfTwoPoints:location b:[[imageView.shoulderVertices objectAtIndex:2] CGPointValue]] < dragRadius ||
           [self proximityOfTwoPoints:location b:[[imageView.hipVertices objectAtIndex:0] CGPointValue]] < dragRadius ||
           [self proximityOfTwoPoints:location b:[[imageView.hipVertices objectAtIndex:1] CGPointValue]] < dragRadius ||
           [self proximityOfTwoPoints:location b:[[imageView.hipVertices objectAtIndex:2] CGPointValue]] < dragRadius)
        {
            return true;
        }
    }
    return false;
}

/*
 Handles the dragging movement for the angle finders
 */
- (void) moveVertex:(UIPanGestureRecognizer *)sender
{
    CGPoint vertex;
    CGPoint translation = [sender translationInView:[self view]];
    CGPoint location = [sender locationInView:[self view]];
    LegAngleImageView* imageView = (LegAngleImageView*)previewImage;

    //Gesture is beginning, so this time around we simply setup for the
    //future calls.
    if([sender state] == UIGestureRecognizerStateBegan)
    {
        //Check whether the drage gesture is near a knee angle vertex
        for(int i = 0; i < 3; i++ )
        {
            vertex = [[imageView.kneeVertices objectAtIndex:i] CGPointValue];
            if([self proximityOfTwoPoints:location b:vertex]< dragRadius)
            {
                movingVerticeArray = imageView.kneeVertices;
                indexOfMovingPoint = i;
                xOffset = vertex.x;
                yOffset = vertex.y;
                break;
            }
        }
        //Check whether the drage gesture is near a knee angle vertex
        for(int i = 0; i < 3; i++ )
        {
            vertex = [[imageView.shoulderVertices objectAtIndex:i] CGPointValue];
            if([self proximityOfTwoPoints:location b:vertex]< dragRadius)
            {
                movingVerticeArray = imageView.shoulderVertices;
                indexOfMovingPoint = i;
                xOffset = vertex.x;
                yOffset = vertex.y;
                break;
            }
        }
        for(int i = 0; i < 3; i++ )
        {
            vertex = [[imageView.hipVertices objectAtIndex:i] CGPointValue];
            if([self proximityOfTwoPoints:location b:vertex]< dragRadius)
            {
                movingVerticeArray = imageView.hipVertices;
                indexOfMovingPoint = i;
                xOffset = vertex.x;
                yOffset = vertex.y;
                break;
            }
        }
    }
    else if([sender state] == UIGestureRecognizerStateEnded)
    {
        xOffset = 0;
        yOffset = 0;
        indexOfMovingPoint = -1;
    }
    else if(indexOfMovingPoint > -1)
    {
        vertex.x = xOffset + translation.x;
        vertex.y = yOffset + translation.y;
        
        NSValue *vertexValue = [NSValue valueWithCGPoint:vertex];
        [movingVerticeArray setObject:vertexValue atIndexedSubscript:indexOfMovingPoint];
    
        [imageView setNeedsDisplay];
        
    }
    
    if(movingVerticeArray == imageView.kneeVertices)
    {
        int intAngle = (int)([imageView kneeAngle] * 57.2957795);
        NSString *kneeButtonText = [NSString stringWithFormat:@"Knee Flexion %d°\nKnee Angle %d° ",
                                    180-intAngle,
                                    intAngle];
        [kneeAngleButton setTitle:kneeButtonText forState:UIControlStateNormal];
    }
    else if(movingVerticeArray == imageView.shoulderVertices)
    {
        int intAngle = (int)([imageView shoulderAngle] * 57.2957795);
        NSString *kneeButtonText = [NSString stringWithFormat:@"Shoulder Flexion %d°",intAngle];
        [shoulderAngleButton setTitle:kneeButtonText forState:UIControlStateNormal];
    }
    else if(movingVerticeArray == imageView.hipVertices)
    {
        int intAngle = (int)([imageView hipAngle] * 57.2957795);
        NSString *kneeButtonText = [NSString stringWithFormat:@"Hip Flexion %d°",intAngle];
        [HipAngleButton setTitle:kneeButtonText forState:UIControlStateNormal];
    }
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{}
       
       
- (float) proximityOfTwoPoints:(CGPoint) a b:(CGPoint)b
{
    float value = sqrt(pow(a.x - b.x,2) + pow(a.y-b.y, 2));
    return value;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) stopCapturing
{
    [super stopCapturing];
    LegAngleImageView *imageView = (LegAngleImageView *)previewImage;
    imageView.kneeVertices = [NSMutableArray arrayWithObjects:
                                [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width *.4,self.view.frame.size.height *.4)],
                                [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width *.6,self.view.frame.size.height *.6)],
                                [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width *.8,self.view.frame.size.height *.8)], nil];
    
    imageView.shoulderVertices = [NSMutableArray arrayWithObjects:
                                  [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width *.15,self.view.frame.size.height *.15)],
                                  [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width *.35,self.view.frame.size.height *.45)],
                                  [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width *.55,self.view.frame.size.height *.55)], nil];
    imageView.hipVertices = [NSMutableArray arrayWithObjects:
                             [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width *.6,self.view.frame.size.height *.6)],
                             [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width *.7,self.view.frame.size.height *.7)],
                             [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width *.8,self.view.frame.size.height *.8)], nil];
    [imageView setNeedsDisplay];
    
    [saveButton setHidden:false];
    [kneeAngleButton setHidden:false];
    [shoulderAngleButton setHidden:false];
    [HipAngleButton setHidden:false];
}

- (IBAction)saveAngle
{
    //For the note
    AngleNote *note = [[AngleNote alloc] init];
    LegAngleImageView *imageView = (LegAngleImageView *)previewImage;

    if(imageView.drawKneePath)
    {
        [note setKneeAngle:imageView.kneeAngle];
        [note setKneeVertices:imageView.kneeVertices];
    }
    
    if(imageView.drawShoulderPath)
    {
        [note setShoulderAngle:imageView.shoulderAngle];
        [note setShoulderVertices:imageView.shoulderVertices];
    }
    
    if(imageView.drawHipPath)
    {
        [note setHipAngle:imageView.hipAngle];
        [note setHipVertices:imageView.hipVertices];
    }
    

    //[note setPath:[(LegAngleImageView *)previewImage kneePath]];
    [note setImage:UIImageJPEGRepresentation([self imageFromCurrentTime], 1)];
    [bikeInfo addNote:note];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)setVertices:(NSMutableArray *)vertices;
{
    [(LegAngleImageView *)previewImage setKneeVertices:vertices];
}



@end
