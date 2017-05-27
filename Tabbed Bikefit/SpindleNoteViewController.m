//
//  SpindleNoteViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 2/26/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "SpindleNote.h"
#import "SpindleNoteViewController.h"
#import "Util.h"

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
    
    rightFootGraphic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cleat_fa_right.png"]];
    rightFootGraphic.frame = self.view.frame;
    rightFootGraphic.hidden = YES;
    rightFootGraphic.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:rightFootGraphic];
    
    leftFootTextImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cleat_fa_left_text.png"]];
    leftFootTextImageView.contentMode = UIViewContentModeScaleAspectFit;
    leftFootTextImageView.frame = self.view.frame;
    leftFootTextImageView.hidden = YES;
    [self.view addSubview:leftFootTextImageView];

    rightFootTextImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cleat_fa_right_text.png"]];
    rightFootTextImageView.contentMode = UIViewContentModeScaleAspectFit;
    rightFootTextImageView.frame = self.view.frame;
    rightFootTextImageView.hidden = YES;
    [self.view addSubview:rightFootTextImageView];
    
    spindleView = [[SpindleView alloc] initWithFrame:self.view.frame];
    spindleView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:spindleView];
    
    UIImage *spindleImage = [UIImage imageNamed:@"cleat_left_spindle.png"];
    spindleImageView = [[UIImageView alloc] initWithImage:spindleImage];
    
    spindleImageView.frame = CGRectMake(0,
                                        0,
                                        CGRectGetWidth(self.view.frame),
                                        spindleImage.size.height);
    
    spindleImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self centerSpindle];
    [self.view addSubview:spindleImageView];
    
    [self.view bringSubviewToFront:rightFootTextImageView];
    [self.view bringSubviewToFront:leftFootTextImageView];
    
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
    
    [Util setScreenLeftRightTitle:self leftSelected:[self.bikeInfo leftNotesSelected] key:@"ScreenTitle_CleatForeAft"];

    if([self.bikeInfo leftNotesSelected])
    {
        [leftFootGraphic setHidden:false];
        [rightFootGraphic setHidden:true];
        [leftFootTextImageView setHidden:false];
        [rightFootTextImageView setHidden:true];
        spindleImageView.image = [UIImage imageNamed:@"cleat_left_spindle.png"];
    }
    else
    {
        [leftFootGraphic setHidden:true];
        [rightFootGraphic setHidden:false];
        [leftFootTextImageView setHidden:true];
        [rightFootTextImageView setHidden:false];
        spindleImageView.image = [UIImage imageNamed:@"cleat_right_spindle.png"];
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
    [self setSpindlePosition:location.y];
}

- (void)setSpindlePosition:(CGFloat)y
{
    [spindleView setSpindleYPosition:y];
    spindleImageView.center = CGPointMake(spindleImageView.center.x, y);
}

- (void)centerSpindle
{
    float scale = MIN(CGRectGetWidth(leftFootGraphic.frame)/leftFootGraphic.image.size.width,
                      CGRectGetHeight(leftFootGraphic.frame)/leftFootGraphic.image.size.height);
    float scaledHeight = leftFootGraphic.image.size.height * scale;
    //the marks for the spindle range are at 25% and 37% of height of image
    float spacing = (CGRectGetHeight(leftFootGraphic.frame) - scaledHeight) * 0.5;
    float minYOfBox = (scaledHeight * 0.244) + spacing;
    float maxYOfBox = (scaledHeight * 0.376) + spacing;
    float center = (minYOfBox + maxYOfBox) * 0.5;
    [self setSpindlePosition:center];
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
    [self.bikeInfo addNote:note];
    [self.navigationController popToViewController:self.bikeInfo animated:YES];

}
@end
