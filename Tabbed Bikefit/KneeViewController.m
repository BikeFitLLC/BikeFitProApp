//
//  KneeViewController.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 9/28/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "KneeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AthletePropertyModel.h"

@interface KneeViewController ()
{

}

@end

@implementation KneeViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    previewImage = [previewImage init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(videoUrl)
    {
        [self stopCapturing];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)moveLazerLeft:(id)sender
{
    [(KneeDrawingView *)previewImage moveLazer:-5];
    [(KneeDrawingView *)previewImage setNeedsDisplay];
    
}

- (IBAction)moveLazerRight:(id)sender
{
    [(KneeDrawingView *)previewImage moveLazer:5];
    [(KneeDrawingView *)previewImage setNeedsDisplay];
}

- (IBAction)keepLine:(id)sender
{
    KneeViewNote *note = [[KneeViewNote alloc] init];
    
    [note setPath:[(KneeDrawingView *)previewImage path]];
    [note setLazerPath:[(KneeDrawingView *)previewImage lazerPath]];
    [note setVideoUrl:videoUrl];
    
    [bikeInfo addNote:note];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void) stopCapturing
{
    [super stopCapturing];
    [(KneeDrawingView *)previewImage stopLazer];
    [nextImageButton setHidden:NO];
    [previousImageButton setHidden:NO];
    [saveButton setHidden:NO];
    [recordButton setHidden:YES];
    
}
@end
