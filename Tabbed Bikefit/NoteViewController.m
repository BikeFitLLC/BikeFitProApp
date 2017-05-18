//
//  NoteViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 2/26/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "NoteViewController.h"

@interface NoteViewController ()

@end

@implementation NoteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)addNoteAndDismiss:(FitNote *)note
{
    [self.bikeInfo addNote:note];
    [self.navigationController popToViewController:self.bikeInfo animated:YES];
}

- (UIAlertController *)amazonUploadErrorAlertController:(NSString *)errorMessage
{
    if (!errorMessage) {
        errorMessage = @"We're sorry, we could not sync the data with the server.  Please make sure you have a stable internet connection and try again";
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"An upload error has occurred"
                                                                             message:errorMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:cancelAction];
    return alertController;
}

@end
