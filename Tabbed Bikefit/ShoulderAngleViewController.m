//
//  ShoulderAngleViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 2/28/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "ShoulderAngleViewController.h"
#import "ShoulderAngleNote.h"

@interface ShoulderAngleViewController ()

@end

@implementation ShoulderAngleViewController

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
    labelText = @"Shoulder Angle";

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveAngle
{
    //For the note
    ShoulderAngleNote *note = [[ShoulderAngleNote alloc] init];
    [note setLabelText:labelText];
    
    [note setAngle:[(LegAngleImageView*)previewImage angle]];
    [note setVertices:[(LegAngleImageView*)previewImage vertices]];
    [note setPath:[(LegAngleImageView *)previewImage path]];

    [note setImage:UIImageJPEGRepresentation([self imageFromCurrentTime], 1)];
    
    
    [bikeInfo addNote:note];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
