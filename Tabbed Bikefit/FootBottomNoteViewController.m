//
//  FootBottomNoteViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 12/16/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "FootBottomNoteViewController.h"
#import "FootBottomView.h"

@interface FootBottomNoteViewController ()

@end

@implementation FootBottomNoteViewController

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
    leftFootImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ho_foot_Arches_left.png"]];
    leftFootImage.contentMode = UIViewContentModeScaleAspectFit;
    leftFootImage.frame = self.view.frame;
    leftFootImage.hidden = YES;
    [self.view addSubview:leftFootImage];
    
    rightFootImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ho_foot_Arches_right.png"]];
    rightFootImage.frame = self.view.frame;
    rightFootImage.hidden = YES;
    rightFootImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:rightFootImage];
    
    footBottomView = [[FootBottomView alloc] initWithFrame:self.view.frame];
    footBottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:footBottomView];
    
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
    [saveButton setTitle:@"Save Location" forState:UIControlStateNormal];
    [saveButton setCenter:CGPointMake(self.view.bounds.size.width * .85,
                                        self.view.bounds.size.height *.75)];
    [saveButton addTarget:self action:@selector(saveLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    if([bikeInfo leftNotesSelected])
    {
        [leftFootImage setHidden:false];
        [rightFootImage setHidden:true];
    }
    else
    {
        [leftFootImage setHidden:true];
        [rightFootImage setHidden:false];
    }
}

- (IBAction) saveLocation:(id)sender
{
    FootBottomNote *note = [[FootBottomNote alloc] init];
    [note setCenterOfPressure:footBottomView.lastTouchLocation];
    [note setFootBoxPath:footBottomView.footBoxPath];
    [bikeInfo addNote:note];
    
    [self.navigationController popToViewController:bikeInfo animated:YES];
}

@end
