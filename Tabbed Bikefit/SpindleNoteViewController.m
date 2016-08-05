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
    leftFootGraphic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cleat_fa_left.png"]];
    leftFootGraphic.contentMode = UIViewContentModeScaleAspectFit;
    leftFootGraphic.frame = self.view.frame;
    leftFootGraphic.hidden = YES;
    [self.view addSubview:leftFootGraphic];
    
    rightFootGraphic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cleat_fa_left.png"]];
    rightFootGraphic.frame = self.view.frame;
    rightFootGraphic.hidden = YES;
    rightFootGraphic.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:rightFootGraphic];
    
    spindleView = [[SpindleView alloc] initWithFrame:self.view.frame];
    spindleView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:spindleView];

    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    saveButton.frame = CGRectMake(self.view.frame.size.width * .8,
                                  self.view.frame.size.height * .9,
                                  self.view.frame.size.width * .2,
                                  self.view.frame.size.width * .1);
    saveButton.titleLabel.font = [UIFont systemFontOfSize:24];
    saveButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    saveButton.backgroundColor = [UIColor blackColor];
    saveButton.alpha = .5;
    saveButton.titleLabel.numberOfLines = 2;
    saveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setCenter:CGPointMake(self.view.bounds.size.width * .85,
                                      self.view.bounds.size.height *.75)];
    [saveButton addTarget:self action:@selector(saveNote:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];

    
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 2;
    [panGesture setDelegate:self];

    [self.view addGestureRecognizer:panGesture];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([bikeInfo leftNotesSelected])
    {
        [leftFootGraphic setHidden:false];
        [rightFootGraphic setHidden:true];
    }
    else
    {
        [leftFootGraphic setHidden:true];
        [rightFootGraphic setHidden:false];
    }
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

- (float)calculateMidpoint
{
    float scale = MIN(CGRectGetWidth(leftFootGraphic.frame)/leftFootGraphic.image.size.width,
                      CGRectGetHeight(leftFootGraphic.frame)/leftFootGraphic.image.size.height);
    float scaledHeight = leftFootGraphic.image.size.height * scale;
    //the marks for the spindle range are at 25% and 37% of height of image
    float spacing = (CGRectGetHeight(leftFootGraphic.frame) - scaledHeight) * 0.5;
    float minYOfBox = (scaledHeight * 0.244) + spacing;
    float maxYOfBox = (scaledHeight * 0.376) + spacing;
    float spindlePosition = spindleView.spindleYPosition;

    float percent = (spindlePosition - minYOfBox) / (maxYOfBox - minYOfBox);
    return percent;
}

- (IBAction)saveNote:(id)sender
{
    SpindleNote *note = [[SpindleNote alloc]init];
    [note setYPositionAsPercent:[self calculateMidpoint]];
    [ bikeInfo addNote:note];
    [self.navigationController popToViewController:bikeInfo animated:YES];

}
@end
