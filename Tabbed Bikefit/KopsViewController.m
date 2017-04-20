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
#import "SVProgressHUD.h"

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
    [self uploadNote];
}

- (void)uploadNote
{
    [SVProgressHUD showWithStatus:@"Uploading..."];
    KopsNote *note = [[KopsNote alloc] init];
    
    [note setPath:[(KneeDrawingView *)previewImage lazerPath]];
    
    __weak KopsViewController *weakSelf = self;
    
    [note uploadImageData:UIImageJPEGRepresentation([self imageFromCurrentTime],1) callback:^(BOOL success, NSString *errorMessage) {
        [SVProgressHUD dismiss];
        NSLog(@"😴upload %@",success ? @"success" : @"failed");
        if (!success) {
            [weakSelf amazonUploadError:errorMessage];
        } else {
            [weakSelf addNoteAndDismiss:note];
        }
    }];
}

- (void)amazonUploadError:(NSString *)message
{
    UIAlertController *alertController = [self amazonUploadErrorAlertController:nil];
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self uploadNote];
    }];
    
    [alertController addAction:retryAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void) stopCapturing
{
    [super stopCapturing];
    [(KneeDrawingView *) previewImage setDrawingEnabled:false];
}
@end
