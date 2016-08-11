//
//  GUIFootPressureImageViewController.m
//  bikefit
//
//  Created by Developer on 8/4/16.
//

#import "GUIFootPressureImageViewController.h"

@interface GUIFootPressureImageViewController ()
{
    UIImageView *_imageView;
}
@end

@implementation GUIFootPressureImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _imageView.backgroundColor = [UIColor whiteColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.image = [UIImage imageNamed:self.imageName];
    self.view = _imageView;
}

@end
