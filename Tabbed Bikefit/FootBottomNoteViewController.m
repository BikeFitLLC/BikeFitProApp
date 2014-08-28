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
	// Do any additional setup after loading the view.
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
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
