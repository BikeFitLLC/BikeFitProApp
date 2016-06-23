    //
//  SideViewViewController.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 5/31/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "SideViewViewController.h"
#import "BikeFitTabBarController.h"
#import "LegAngleViewController.h"

@interface SideViewViewController ()

@end

@implementation SideViewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[foreAftControl addTarget:self action:@selector(onForeAftChanged:) forControlEvents:UIControlEventAllEvents];
    //[self loadFieldsFromPropertyModel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadFieldsFromPropertyModel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

-(IBAction) onTextFieldChanged: (UITextField*)field
{
    [AthletePropertyModel setProperty:[self propertyNameFromTag:field.tag] value:field.text];
    return;
}

-(IBAction) onButtonFieldChanged:(UIButton*) button
{
    NSString *title = [[button titleLabel] text];
    [AthletePropertyModel setProperty:[self propertyNameFromTag:button.tag] value:title];
    return;
}

-(IBAction) save{
    [AthletePropertyModel saveAthlete];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    // Get reference to the destination view controller
    LegAngleViewController *vc = [segue destinationViewController];
    
    NSString *ident = [segue identifier];
    if([ident compare:[NSString stringWithFormat:@"BeforeLegAngleVideo"]] == 0)
    {
        [vc setPropertyName:[self propertyNameFromTag:legAngleBeforeField.tag]];
    }
    else if([ident compare:[NSString stringWithFormat:@"AfterLegAngleVideo"]] == 0)
    {
        [vc setPropertyName:[self propertyNameFromTag:legAngleAfterField.tag]];
    }
    
}

- (void) onForeAftChanged:(id)sender
{
    NSString * value;
    switch([foreAftControl selectedSegmentIndex])
    {
        case 0:
            value = @"aft";
            break;
        case 1:
            value = @"good"; //TODO: put these values in another file
            break;
        case 2:
            value = @"fore";
            break;
    }
    [AthletePropertyModel setProperty:[self propertyNameFromTag:foreAftControl.tag] value:value];
    return;
}

- (NSString*) propertyNameFromTag:(int)tag
{
    NSString *propertyName;
    switch(tag)
    {
        case SaddleChange:
            propertyName = @"SaddleChange";
            break;
        case SaddleForeAft:
            propertyName = @"SaddleForeAft";
            break;
        case LegAngleBefore:
            propertyName = @"LegAngleBefore";
            break;
        case LegAngleAfter:
            propertyName = @"LegAngleAfter";
            break;
        default:
            [NSException raise:@"Invalid Control Tag" format:@"Tag ID %d is invalid", tag];
    }
    return propertyName;
}

enum FieldNames
{
    SaddleChange = 0,
    SaddleForeAft = 1,
    LegAngleBefore = 2,
    LegAngleAfter = 3,

};

- (void) loadFieldsFromPropertyModel
{
    [legAngleBeforeField setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:LegAngleBefore]]];
    [legAngleAfterField setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:LegAngleAfter]]];
    [saddleChange setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:SaddleChange]]];
    
    
    NSData *imageData =[AthletePropertyModel getProperty:@"testimage"];
    if( imageData)
    {
        UIImage *savedAngleImage = [[UIImage alloc] initWithData:imageData];
        [savedImageView setImage:savedAngleImage];
    }
    
    
    
}



@end
