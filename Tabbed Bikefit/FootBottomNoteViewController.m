//
//  FootBottomNoteViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 12/16/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "FootBottomNoteViewController.h"
#import "GUIFootPressureImageViewController.h"
#import "UIColor+CustomColor.h"
#import "Util.h"

@interface FootBottomNoteViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
{
    UIPageViewController *_pageViewController;
}

@end

@implementation FootBottomNoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bikeFitBlue];

    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];

    _pageViewController.dataSource = self;
    float navHeight = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    [_pageViewController.view setFrame:CGRectMake(0, navHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - navHeight)];

    GUIFootPressureImageViewController *initialViewController = [self viewControllerAtIndex:0];

    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];

    [_pageViewController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];

    [self addChildViewController:_pageViewController];
    [self.view addSubview:[_pageViewController view]];
    [_pageViewController didMoveToParentViewController:self];

    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    saveButton.frame = CGRectMake(self.view.frame.size.width * .8,
                                    self.view.frame.size.height * .9,
                                    self.view.frame.size.width * .2,
                                    self.view.frame.size.width * .1);
    saveButton.titleLabel.font = [UIFont systemFontOfSize:24];
    saveButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    saveButton.backgroundColor = [UIColor bikeFitBlue];
    saveButton.layer.cornerRadius = 4;
    saveButton.alpha = .75;
    saveButton.titleLabel.numberOfLines = 2;
    saveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setCenter:CGPointMake(self.view.bounds.size.width * .85,
                                        self.view.bounds.size.height *.75)];
    [saveButton addTarget:self action:@selector(saveLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [Util setScreenLeftRightTitle:self leftSelected:[bikeInfo leftNotesSelected] key:@"ScreenTitle_FootPressure"];
}

- (IBAction)saveLocation:(id)sender
{
    GUIFootPressureImageViewController *currentVC = (GUIFootPressureImageViewController *)_pageViewController.viewControllers.firstObject;

    FootBottomNote *note = [[FootBottomNote alloc] init];
    [note setFootPressure:currentVC.index];
    [bikeInfo addNote:note];

    [self.navigationController popToViewController:bikeInfo animated:YES];
}

#pragma mark - UIPageViewController delegate/datasource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    NSUInteger index = [(GUIFootPressureImageViewController *)viewController index];

    index = index == 0 ? 3 : index - 1;
    return [self viewControllerAtIndex:index];
}

- (GUIFootPressureImageViewController *)viewControllerAtIndex:(NSUInteger)index {

    GUIFootPressureImageViewController *childViewController = [[GUIFootPressureImageViewController alloc] init];
    childViewController.index = index;
    NSString *imageName = [NSString stringWithFormat:@"%ld_foot_pressure.png",index];
    [childViewController setImageName:imageName];
    return childViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {

    NSUInteger index = [(GUIFootPressureImageViewController *)viewController index];

    index = index == 3 ? 0 : index + 1;
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 4;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

@end
