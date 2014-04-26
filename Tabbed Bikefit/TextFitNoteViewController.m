//
//  TextFitNoteViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 12/11/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "TextFitNoteViewController.h"

@interface TextFitNoteViewController ()

@end

@implementation TextFitNoteViewController

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
- (IBAction) addBtnPressed:(id)sender
{
    FitNote *note = [[FitNote alloc] init];
    [note setText:textField.text];
    [bikeInfo addNote:note];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
