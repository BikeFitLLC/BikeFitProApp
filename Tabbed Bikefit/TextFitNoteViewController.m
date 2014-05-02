//
//  TextFitNoteViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 12/11/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "TextFitNoteViewController.h"

@interface TextFitNoteViewController ()
{
    NSMutableArray *automaticNotesList;
}

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
    [saddleNotePicker setDelegate:self];
    automaticNotesList = [[NSMutableArray alloc] init];

    [automaticNotesList addObject:@"Saddle Up"];
    [automaticNotesList addObject:@"Saddle Down"];
    [automaticNotesList addObject:@"Saddle Forward"];
    [automaticNotesList addObject:@"Saddle Saddle Back"];
    [automaticNotesList addObject:@"Moved Foot Lateral"];
    [automaticNotesList addObject:@"Moved Foot Medial"];
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

#pragma UIPickerView Delegate and DataSource methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [automaticNotesList count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [automaticNotesList objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [textField setText:[automaticNotesList objectAtIndex:row]]; 
    
}

@end
