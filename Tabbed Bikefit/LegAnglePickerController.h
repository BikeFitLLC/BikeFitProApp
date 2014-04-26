//
//  LegAnglePickerController.h
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 9/26/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideViewViewController.h"

@interface LegAnglePickerController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate>{
    IBOutlet UIPickerView *picker;
    UIButton *sendingButton;
    SideViewViewController *callingController;
}
@property (atomic) UIButton *sendingButton;
@property (atomic) SideViewViewController *callingController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;


// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
@end
