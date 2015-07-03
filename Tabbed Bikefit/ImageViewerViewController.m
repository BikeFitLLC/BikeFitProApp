//
//  ImageViewerViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 3/27/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "ImageViewerViewController.h"
#import "DrawingView.h"

@interface ImageViewerViewController ()

@end

@implementation ImageViewerViewController
@synthesize image;
@synthesize overlayPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    imageView = [[UIImageView alloc] initWithImage:self.image];
    imageView.frame = self.view.frame;
    imageView.center = self.view.center;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
    
    drawingView = [[DrawingView alloc] initWithFrame:self.view.frame];
    drawingView.backgroundColor = [UIColor clearColor];
    drawingView.overlayPath = overlayPath;
    [self.view addSubview:drawingView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //CGRect bounds = CGRectMake(0,0,720, 1024);// self.view.layer.bounds;
    //[self.view setFrame:bounds];
    //[self.view setFrame:bounds];
    
    //[previewImage setFrame:bounds];
    
    [imageView setImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    //[imageView setBounds:bounds];
    //[imageView setFrame:bounds];
    //[imageView setCenter:CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))];
    if(overlayPath)
    {
        
        //previewImage.drawingView.overlayPath = overlayPath;
        //[previewImage setNeedsDisplay];
    }
    

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
