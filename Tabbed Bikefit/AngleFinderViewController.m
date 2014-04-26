//
//  LegAngleViewController.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 10/1/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "AngleFinderViewController.h"
#import "AthletePropertyModel.h"
#import <QuartzCore/QuartzCore.h>
#import <math.h>

@interface AngleFinderViewController (){
    int vertexIndex;
    
    int indexOfMovingPoint;
    CGFloat xOffset;
    CGFloat yOffset;
}
@end

@implementation AngleFinderViewController
@synthesize propertyName;
@synthesize labelText;
@synthesize angle;

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
    angleLabel.font = [UIFont fontWithName:@"Helvetica" size:100.0];
    angleLabel.text = [NSString stringWithFormat:@"%d°", (int)(angle/0.0174532925)];
    
    labelText = @"Leg Angle";
    vertexIndex = 0;
    //capture = false;
    //displayedImageIndex = 0;
    indexOfMovingPoint = -1;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveVertex:)];
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 2;
    [panGesture setDelegate:self];

    [self.view addGestureRecognizer:panGesture];

}

/*
 Handles the dragging movement for the angle finder
 */
- (void) moveVertex:(UIPanGestureRecognizer *)sender
{
    CGPoint vertex;
    CGPoint translation = [sender translationInView:[self view]];
    CGPoint location = [sender locationInView:[self view]];
    LegAngleImageView* imageView = (LegAngleImageView*)previewImage;

    if([sender state] == UIGestureRecognizerStateBegan)
    {
        if(vertexIndex == 0 && [imageView.vertices count] == 3)
        {
            for(int i = 0; i < 3; i++ )
            {
                vertex = [[imageView.vertices objectAtIndex:i] CGPointValue];
                if([self proximityOfTwoPoints:location b:vertex]< dragRadius)
                {
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
        
        LegAngleImageView *imageView = (LegAngleImageView *)previewImage;
        
        NSValue *vertexValue = [NSValue valueWithCGPoint:vertex];
        [imageView.vertices setObject:vertexValue atIndexedSubscript:indexOfMovingPoint];
        [imageView calculateAngle];
        
        [imageView drawAngle:[[imageView.vertices objectAtIndex:0] CGPointValue]
                              b:[[imageView.vertices objectAtIndex:1] CGPointValue]
                              c:[[imageView.vertices objectAtIndex:2] CGPointValue]
                                ];
        
    }
    
    [angleLabel setText:[NSString stringWithFormat:@"%d°",(int)([imageView angle] * 57.2957795)]];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    LegAngleImageView* imageView = (LegAngleImageView*)previewImage;
    
    if(vertexIndex == 0 && [imageView.vertices count] == 3)
    {
        CGPoint location = [gestureRecognizer locationInView:[self view]];
        if([self proximityOfTwoPoints:location b:[[imageView.vertices objectAtIndex:0] CGPointValue]] < dragRadius ||
           [self proximityOfTwoPoints:location b:[[imageView.vertices objectAtIndex:1] CGPointValue]] < dragRadius ||
           [self proximityOfTwoPoints:location b:[[imageView.vertices objectAtIndex:2] CGPointValue]] < dragRadius)
        {
            return true;
        }
    }
    return false;
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
    imageView.vertices = [NSMutableArray arrayWithObjects:
                [NSValue valueWithCGPoint:CGPointMake(300,300)],
                [NSValue valueWithCGPoint:CGPointMake(400,400)],
                [NSValue valueWithCGPoint:CGPointMake(300,500)], nil];
    [imageView calculateAngle];
    [imageView drawAngle:[[imageView.vertices objectAtIndex:0] CGPointValue]
                       b:[[imageView.vertices objectAtIndex:1] CGPointValue]
                       c:[[imageView.vertices objectAtIndex:2] CGPointValue]
                        ];
    [angleLabel setText:[NSString stringWithFormat:@"%d°",(int)([imageView angle] * 57.2957795)]];
}

- (IBAction)saveAngle
{
    //For the note
    AngleNote *note = [[AngleNote alloc] init];
    [note setLabelText:labelText];
    
    [note setAngle:angle];

    LegAngleImageView *imageView = (LegAngleImageView *)previewImage;
    [note setVertices:imageView.vertices];
    [note setAngle:[imageView angle]];
    [note setPath:[(LegAngleImageView *)previewImage path]];
    [note setImage:UIImageJPEGRepresentation([self imageFromCurrentTime], 1)];
    
    [bikeInfo addNote:note];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)setVertices:(NSMutableArray *)vertices;
{
    [(LegAngleImageView *)previewImage setVertices:vertices];
}



@end
