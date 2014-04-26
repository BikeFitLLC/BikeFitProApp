//
//  KopsViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 3/4/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "KopsViewController.h"
#import "KopsNote.h"
#import "AthletePropertyModel.h"

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
	// Do any additional setup after loading the view.
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
    
    [bikeInfo addNote:note];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end