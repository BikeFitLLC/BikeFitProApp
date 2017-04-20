//
//  Saddle Fore/Aft
//
//  KopsViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 3/4/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "AthletePropertyModel.h"
#import "KopsNote.h"
#import "KopsViewController.h"
#import "Util.h"

@interface KopsViewController ()

@end

@implementation KopsViewController

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
    [saveButton addTarget:self action:@selector(keepLine:) forControlEvents:UIControlEventTouchUpInside];
	// Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [Util setScreenLeftRightTitle:self leftSelected:[self.bikeInfo leftNotesSelected] key:@"ScreenTitle_SaddleForeAft"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)keepLine:(id)sender
{
    KopsNote *note = [[KopsNote alloc] init];

    [note setPath:[(KneeDrawingView *)previewImage lazerPath]];
    [note setImage:UIImageJPEGRepresentation([self imageFromCurrentTime], 1)];
    
    [self.bikeInfo addNote:note];
    [self.navigationController popToViewController:self.bikeInfo animated:YES];
}

- (void) stopCapturing
{
    [super stopCapturing];
    [(KneeDrawingView *) previewImage setDrawingEnabled:false];
}
@end
