//
//  LegAngleViewController.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 10/1/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "AthletePropertyModel.h"
#import "GoniometerViewController.h"
#import "Util.h"
#import "SVProgressHUD.h"

#import <math.h>
#import <QuartzCore/QuartzCore.h>

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
    
    previewImage = [[GoniometerDrawingView alloc] initWithFrame:self.view.frame];
    previewImage.backgroundColor = [UIColor clearColor];
    [self.view addSubview:previewImage];
    
    [self.view bringSubviewToFront:videoToolBarView];
    [self.view bringSubviewToFront:recordButton];
    [self.view bringSubviewToFront:saveButton];
    [self.view bringSubviewToFront:previousImageButton];
    [self.view bringSubviewToFront:nextImageButton];
    [self.view bringSubviewToFront:reverseCameraButton];
    
    
    CGFloat oneThirdViewWidth = self.view.frame.size.width/3;
    
    kneeAngleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGFloat height = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    kneeAngleButton.frame = CGRectMake(0,
                                       height,
                                       oneThirdViewWidth,
                                       oneThirdViewWidth * .4);
    kneeAngleButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
    kneeAngleButton.backgroundColor = [UIColor greenColor];
    kneeAngleButton.alpha = .7;
    kneeAngleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [kneeAngleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [kneeAngleButton setTitle:@"Knee" forState:UIControlStateNormal];
    kneeAngleButton.hidden = YES;
    [kneeAngleButton addTarget:self action:@selector(enableAngle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:kneeAngleButton];
    
    shoulderAngleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    shoulderAngleButton.frame = CGRectMake(oneThirdViewWidth,
                                           height,
                                           oneThirdViewWidth,
                                           oneThirdViewWidth * .4);
    shoulderAngleButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
    shoulderAngleButton.backgroundColor = [UIColor orangeColor];
    shoulderAngleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    shoulderAngleButton.alpha = .7;
    [shoulderAngleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shoulderAngleButton setTitle:@"Shoulder" forState:UIControlStateNormal];
    shoulderAngleButton.hidden = YES;
    [shoulderAngleButton addTarget:self action:@selector(enableAngle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shoulderAngleButton];
    
    HipAngleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    HipAngleButton.frame = CGRectMake(2*oneThirdViewWidth,
                                      height,
                                      oneThirdViewWidth,
                                      oneThirdViewWidth * .4);
    HipAngleButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
    HipAngleButton.backgroundColor = [UIColor purpleColor];
    HipAngleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    HipAngleButton.alpha = .7;
    [HipAngleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [HipAngleButton setTitle:@"Hip" forState:UIControlStateNormal];
    HipAngleButton.hidden = YES;
    [HipAngleButton addTarget:self action:@selector(enableAngle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:HipAngleButton];
    
    vertexIndex = 0;
    indexOfMovingPoint = -1;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveVertex:)];
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 2;
    [panGesture setDelegate:self];

    [self.view addGestureRecognizer:panGesture];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [Util setScreenLeftRightTitle:self leftSelected:[self.bikeInfo leftNotesSelected] key:@"ScreenTitle_Goniometer"];
}

- (void)enableAngle:(id)sender
{
    GoniometerDrawingView* imageView = (GoniometerDrawingView *)previewImage;
    bool originalState = false;
    
    if(sender == kneeAngleButton)
    {
        originalState = imageView.drawKneePath;
        if(!originalState)
        {
            kneeAngleButton.titleLabel.numberOfLines = 2;
        }
        else
        {
            kneeAngleButton.titleLabel.numberOfLines = 1;
        }
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
    GoniometerDrawingView* imageView = (GoniometerDrawingView*)previewImage;
    
    if(vertexIndex == 0 && [imageView.kneeVertices count] == 3)
    {
        CGPoint location = [gestureRecognizer locationInView:[self view]];
        if( (([self proximityOfTwoPoints:location b:[[imageView.kneeVertices objectAtIndex:0] CGPointValue]] < dragRadius ||
              [self proximityOfTwoPoints:location b:[[imageView.kneeVertices objectAtIndex:1] CGPointValue]] < dragRadius ||
              [self proximityOfTwoPoints:location b:[[imageView.kneeVertices objectAtIndex:2] CGPointValue]] < dragRadius)
                && imageView.drawKneePath )
           ||
           (([self proximityOfTwoPoints:location b:[[imageView.shoulderVertices objectAtIndex:0] CGPointValue]] < dragRadius ||
             [self proximityOfTwoPoints:location b:[[imageView.shoulderVertices objectAtIndex:1] CGPointValue]] < dragRadius ||
             [self proximityOfTwoPoints:location b:[[imageView.shoulderVertices objectAtIndex:2] CGPointValue]] < dragRadius)
                && imageView.drawShoulderPath)
           ||
           (([self proximityOfTwoPoints:location b:[[imageView.hipVertices objectAtIndex:0] CGPointValue]] < dragRadius ||
             [self proximityOfTwoPoints:location b:[[imageView.hipVertices objectAtIndex:1] CGPointValue]] < dragRadius ||
             [self proximityOfTwoPoints:location b:[[imageView.hipVertices objectAtIndex:2] CGPointValue]] < dragRadius)
                && imageView.drawHipPath))
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
    GoniometerDrawingView* imageView = (GoniometerDrawingView*)previewImage;

    //Gesture is beginning, so this time around we simply setup for the
    //future calls.
    if([sender state] == UIGestureRecognizerStateBegan)
    {
        //Check whether the drag gesture is near a knee angle vertex
        if(imageView.drawKneePath)
        {
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
        }
        //Check whether the drage gesture is near a shoulder angle vertex
        if(imageView.drawShoulderPath)
        {
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
        }
        if(imageView.drawHipPath)
        {
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
        shoulderAngleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
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
    GoniometerDrawingView *imageView = (GoniometerDrawingView *)previewImage;
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
    
    [saveButton setEnabled:YES];
    [kneeAngleButton setHidden:false];
    [shoulderAngleButton setHidden:false];
    [HipAngleButton setHidden:false];
}

- (IBAction)saveAngle
{
    [self uploadNote];
}

- (void)uploadNote
{
    [SVProgressHUD showWithStatus:@"Uploading..."];
    AngleNote *note = [[AngleNote alloc] init];
    GoniometerDrawingView *imageView = (GoniometerDrawingView *)previewImage;
    
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

    
    __weak GoniometerViewController *weakSelf = self;
    
    [note uploadImageData:UIImageJPEGRepresentation([self imageFromCurrentTime],1) callback:^(BOOL cloudSaved, BOOL fileSaved, NSError* error) {
        [SVProgressHUD dismiss];
        NSLog(@"😴upload %@",cloudSaved ? @"success" : @"failed");
        if(!fileSaved) {
            NSLog(@"Failed to Save Image to File");
        }
        
        if (!cloudSaved && [AmazonClientManager verifyLoggedInActive] ) {
            [weakSelf amazonUploadError:@"We're sorry, we could not sync the data with the server.  Please make sure you have a stable internet connection and try again"];
        }
        [weakSelf addNoteAndDismiss:note];
    }];
}

- (void)amazonUploadError:(NSString *)message
{
    UIAlertController *alertController = [self amazonUploadErrorAlertController:message];
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self uploadNote];
    }];
    
    [alertController addAction:retryAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)setVertices:(NSMutableArray *)vertices;
{
    [(GoniometerDrawingView *)previewImage setKneeVertices:vertices];
}



@end
