//
//  FirstViewController.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 5/31/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "AthleteInfoController.h"
#import "BikeFitTabBarController.h"
#import "AthletePropertyModel.h"

@interface AthleteInfoController ()

@end

@implementation AthleteInfoController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadFieldsFromPropertyModel];
}

-(IBAction) onFieldChanged: (id) sender
{
    UITextField *field = sender;
    NSString *propertyName = [self propertyNameFromTag:field.tag];
    [AthletePropertyModel setProperty:propertyName value:field.text];
    return;
}

-(IBAction) save{
    [AthletePropertyModel saveAthleteToAWS];
}

-(IBAction) newAthlete{
    [AthletePropertyModel newAthlete];
    [self loadFieldsFromPropertyModel];
}

-(IBAction) moveViewUpForKeyboard:(id)sender
{
    const int movementDistance = -150; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed

    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movementDistance);
    [UIView commitAnimations];
}

-(IBAction) moveViewDownForKeyboard:(id)sender
{
    const int movementDistance = 150; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movementDistance);
    [UIView commitAnimations];
}

- (NSString*) propertyNameFromTag:(int)tag;
{
    NSString *propertyName;
    switch(tag)
    {
        case FirstName:
            propertyName = @"FirstName";
            break;
        case LastName:
            propertyName = @"LastName";
            break;
        case Email:
            propertyName = @"Email";
            break;
        case Address:
            propertyName = @"Address";
            break;
        case Bike:
            propertyName = @"Bike";
            break;
        case BikeModel:
            propertyName = @"BikeModel";
            break;
        case BikeSize:
            propertyName = @"BikeSize";
            break;
        case BikeYear:
            propertyName = @"BikeYear";
            break;
        case Pedals:
            propertyName = @"Pedals";
            break;
        case Shoes:
            propertyName = @"Shoes";
            break;
        case MilesPerWeek:
            propertyName = @"MilesPerWeek";
            break;
        case MilesPerRide:
            propertyName = @"MilesPerRide";
            break;
        case YearsCycling:
            propertyName = @"YearsCycling";
            break;
        case CyclingType:
            propertyName = @"CyclingType";
            break;
        case Saddle:
            propertyName = @"Saddle";
            break;
        case Concerns:
            propertyName = @"Concerns";
            break;
        default:
            [NSException raise:@"Invalid Control Tag" format:@"Tag ID %d is invalid", tag];
    }
    return propertyName;
}

enum FieldNames
{
    FirstName = 0,
    LastName = 1,
    Email = 2,
    Address = 3,
    Bike = 4,
    BikeModel = 5,
    BikeSize = 6,
    BikeYear = 7,
    Pedals = 8,
    Shoes = 9,
    MilesPerWeek = 10,
    MilesPerRide = 11,
    YearsCycling = 12,
    CyclingType = 13,
    Saddle = 14,
    Concerns = 15,
    
};

- (void) loadFieldsFromPropertyModel
{
    [firstName setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:FirstName]]];
    [lastName setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:LastName]]];
    [email setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:Email]]];
    [address setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:Address]]];
    [bike setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:Bike]]];
    [bikeSize setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:BikeSize]]];
    [pedals setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:Pedals]]];
    [shoes setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:Shoes]]];
    [milesPerWeek setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:MilesPerWeek]]];
    [yearsCycling setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:YearsCycling]]];
    [cyclingType setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:CyclingType]]];
    [saddle setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:Saddle]]];
    [concerns setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:Concerns]]];
    

}




@end
