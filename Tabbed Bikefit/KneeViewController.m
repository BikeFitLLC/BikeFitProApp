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
    [saveButton addTarget:self action:@selector(keepLine:) forControlEvents:UIControlEventTouchUpInside];
    previewImage = [[KneeDrawingView alloc] initWithFrame:self.view.frame];
    previewImage.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:previewImage aboveSubview:previewView];
    
    lazerLeftButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    lazerLeftButton.frame = CGRectMake(self.view.frame.size.width * .1,
                                  self.view.frame.size.height * .9,
                                  self.view.frame.size.width * .2,
                                  self.view.frame.size.width * .1);
    lazerLeftButton.titleLabel.font = [UIFont systemFontOfSize:24];
    lazerLeftButton.backgroundColor = [UIColor blackColor];
    lazerLeftButton.alpha = .5;
    [lazerLeftButton setTitle:@"Line Left" forState:UIControlStateNormal];
    [lazerLeftButton addTarget:self action:@selector(moveLazerLeft:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lazerLeftButton];
    
    lazerRightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    lazerRightButton.frame = CGRectMake(self.view.frame.size.width * .8,
                                       self.view.frame.size.height * .9,
                                       self.view.frame.size.width * .2,
                                       self.view.frame.size.width * .1);
    lazerRightButton.titleLabel.font = [UIFont systemFontOfSize:24];
    lazerRightButton.backgroundColor = [UIColor blackColor];
    lazerRightButton.alpha = .5;
    [lazerRightButton setTitle:@"Line Right" forState:UIControlStateNormal];
    [lazerRightButton addTarget:self action:@selector(moveLazerRight:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lazerRightButton];
    
    //previewImage = [previewImage init];
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
    [lazerLeftButton setHidden:NO];
    [lazerRightButton setHidden:NO];
    [recordButton setHidden:YES];
    [playButton setHidden:NO];
    
}
@end
