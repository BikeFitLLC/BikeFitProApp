//
//  SpindleNoteViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 2/26/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "SpindleNoteViewController.h"
#import "SpindleNote.h"

@interface SpindleNoteViewController ()

@end

@implementation SpindleNoteViewController

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
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveSpindleY:)];
    
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 2;
    [panGesture setDelegate:self];

    [self.view addGestureRecognizer:panGesture];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) moveSpindleY:(UIPanGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:[self view]];
    [spindleView setSpindleYPosition:location.y];
    [spindleView setNeedsDisplay];
}

- (IBAction)saveNote
{
    SpindleNote *note = [[SpindleNote alloc]init];
    [note setPath:[spindleView boxPath]];
    [ bikeInfo addNote:note];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}
@end
