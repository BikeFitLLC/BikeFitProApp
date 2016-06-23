//
//  FootViewController.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 9/27/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "FootViewController.h"
#import "AthletePropertyModel.h"

@interface FootViewController ()

@end

@implementation FootViewController

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
    //Setup targets for the controls in this page
	[stepperLeftWedge addTarget:self
                action:@selector(onWedgeStepperChanged:)
                forControlEvents:UIControlEventValueChanged];
    [stepperRightWedge addTarget:self
                          action:@selector(onWedgeStepperChanged:)
               forControlEvents:UIControlEventValueChanged];
    
    //Set up stepper listeners
    [leftVarus addTarget:self action:@selector(onVarusControlChanged:)
        forControlEvents:(UIControlEventValueChanged)];
    [rightVarus addTarget:self action:@selector(onVarusControlChanged:)
        forControlEvents:(UIControlEventValueChanged)];
    
    [leftArch addTarget:self action:@selector(onArchControlChanged:)
        forControlEvents:(UIControlEventValueChanged)];
    [rightArch addTarget:self action:@selector(onArchControlChanged:)
         forControlEvents:(UIControlEventValueChanged)];
    
    [leftCollapse addTarget:self action:@selector(onCollapseControlChanged:)
       forControlEvents:(UIControlEventValueChanged)];
    [rightCollapse addTarget:self action:@selector(onCollapseControlChanged:)
        forControlEvents:(UIControlEventValueChanged)];
    
    [leftRotation addTarget:self action:@selector(onRotationControlChanged:)
           forControlEvents:(UIControlEventValueChanged)];
    [rightRotation addTarget:self action:@selector(onRotationControlChanged:)
            forControlEvents:(UIControlEventValueChanged)];
}

- (void) viewWillAppear:(BOOL)animated
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//called when either left or right wedge stepper
//changes and sets the property in the model
- (void)onWedgeStepperChanged:(id)sender
{
    UIStepper *stepper = sender;
    UILabel *label = rightWedgesLabel;
    
    if([stepper tag] == 1)
    {
        label = leftWedgesLabel;
    }
    
    NSString *propertyName = [self propertyNameFromTag:label.tag];
    NSString *numberofWedges = [NSString stringWithFormat:@"%d", (int)[stepper value]];
    [label setText:numberofWedges];
    [AthletePropertyModel setProperty:propertyName value:[NSNumber numberWithDouble:[stepper value]]];
    
}

- (void)onVarusControlChanged:(id)sender
{
    UISegmentedControl *control = sender;
    UISegmentedControl *varusControl = sender;
    NSString *propertyname = [self propertyNameFromTag: varusControl.tag];
    
    NSString *varusOrValgus;
    switch([control selectedSegmentIndex])
    {
        case 0:
            varusOrValgus = @"Varus";
            break;
        case 1:
            varusOrValgus = @"Neutral";
            break;
        case 2:
            varusOrValgus = @"Valgus";
            break;
    }
    [AthletePropertyModel setProperty:propertyname value:varusOrValgus];
}

- (int)varusControlIndexFromName:(NSString*)name
{
        
        if( [name compare:@"Varus"] == 0)
        {
            return 0;
        }
        if( [name compare:@"Neutral"] == 0)
        {
            return 1;
        }
        if( [name compare:@"Valgus"] == 0)
        {
            return 2;
        }
    return 0;
}

- (void)onArchControlChanged:(id)sender
{
    UISegmentedControl *control = sender;
    UISegmentedControl *varusControl = sender;
    NSString *propertyname = [self propertyNameFromTag: varusControl.tag];
    
    NSString *value;
    switch([control selectedSegmentIndex])
    {
        case 0:
            value = @"Low";
            break;
        case 1:
            value = @"Medium";
            break;
        default:
            value = @"High";
            break;
    }
    [AthletePropertyModel setProperty:propertyname value:value];
}

- (int)archControlIndexFromName:(NSString*)name
{
    
    if( [name compare:@"Low"] == 0)
    {
        return 0;
    }
    if( [name compare:@"Medium"] == 0)
    {
        return 1;
    }
    if( [name compare:@"High"] == 0)
    {
        return 2;
    }
    return 0;
}

- (void)onCollapseControlChanged:(id)sender
{
    UISegmentedControl *control = sender;
    UISegmentedControl *varusControl = sender;
    NSString *propertyname = [self propertyNameFromTag: varusControl.tag];
    
    NSString *value;
    switch([control selectedSegmentIndex])
    {
        case 0:
            value = @"Mild";
            break;
        case 1:
            value = @"Medium";
            break;
        default:
            value = @"Strong";
            break;
    }
    [AthletePropertyModel setProperty:propertyname value:value];
}

- (int)collapseControlIndexFromName:(NSString*)name
{
    
    if( [name compare:@"Mild"] == 0)
    {
        return 0;
    }
    if( [name compare:@"Medium"] == 0)
    {
        return 1;
    }
    if( [name compare:@"Strong"] == 0)
    {
        return 2;
    }
    return 0;
}

- (void)onRotationControlChanged:(id)sender
{
    UISegmentedControl *control = sender;
    UISegmentedControl *varusControl = sender;
    NSString *propertyname = [self propertyNameFromTag: varusControl.tag];
    
    NSString *value;
    switch([control selectedSegmentIndex])
    {
        case 0:
            value = @"Toe In";
            break;
        case 1:
            value = @"Centered";
            break;
        default:
            value = @"Toe Out";
            break;
    }
    [AthletePropertyModel setProperty:propertyname value:value];
}

- (int)rotationControlIndexFromName:(NSString*)name
{
    
    if( [name compare:@"Toe In"] == 0)
    {
        return 0;
    }
    if( [name compare:@"Centered"] == 0)
    {
        return 1;
    }
    if( [name compare:@"Toe Out"] == 0)
    {
        return 2;
    }
    return 0;
}

- (NSString*) propertyNameFromTag:(int)tag
{
    NSString *propertyName;
    switch(tag)
    {
        case 0:
            propertyName = @"RightVarus";
            break;
        case 1:
            propertyName = @"LeftVarus";
            break;
        case 2:
            propertyName = @"RightArch";
            break;
        case 3:
            propertyName = @"LeftArch";
            break;
        case 4:
            propertyName = @"RightCollapse";
            break;
        case 5:
            propertyName = @"LeftCollapse";
            break;
        case 6:
            propertyName = @"RightRotation";
            break;
        case 7:
            propertyName = @"LeftRotation";
            break;
        case 8:
            propertyName = @"RightVarusAngle";
            break;
        case 9:
            propertyName = @"LeftVarusAngle";
            break;
        case 10:
            propertyName = @"RightWedges";
            break;
        case 11:
            propertyName = @"LeftWedges";
            break;
        default:
            [NSException raise:@"Invalid Control Tag" format:@"Tag ID %d is invalid", tag];
    }
    return propertyName;
}

- (void) loadFieldsFromPropertyModel
{
    [rightVarusAngle setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:RightVarusAngle]]];
    [leftVarusAngle setText:[AthletePropertyModel getProperty:[self propertyNameFromTag:LeftVarusAngle]]];
    
    [stepperRightWedge setValue:[[AthletePropertyModel getProperty:[self propertyNameFromTag:RightWedges]] doubleValue]];
    [stepperLeftWedge setValue:[[AthletePropertyModel getProperty:[self propertyNameFromTag:LeftWedges]] doubleValue]];
    [self onWedgeStepperChanged:stepperRightWedge];
    [self onWedgeStepperChanged:stepperLeftWedge];
    
    [leftVarus setSelectedSegmentIndex:[self varusControlIndexFromName:[AthletePropertyModel getProperty:[self propertyNameFromTag:LeftVarus]]]];
    [rightVarus setSelectedSegmentIndex:[self varusControlIndexFromName:[AthletePropertyModel getProperty:[self propertyNameFromTag:RightVarus]]]];
    
    [leftArch setSelectedSegmentIndex:[self archControlIndexFromName:[AthletePropertyModel getProperty:[self propertyNameFromTag:LeftArch]]]];
    [rightArch setSelectedSegmentIndex:[self archControlIndexFromName:[AthletePropertyModel getProperty:[self propertyNameFromTag:RightArch]]]];
    
    [leftCollapse setSelectedSegmentIndex:[self collapseControlIndexFromName:[AthletePropertyModel getProperty:[self propertyNameFromTag:LeftCollapse]]]];
    [rightCollapse setSelectedSegmentIndex:[self collapseControlIndexFromName:[AthletePropertyModel getProperty:[self propertyNameFromTag:RightCollapse]]]];
    
    [leftRotation setSelectedSegmentIndex:[self rotationControlIndexFromName:[AthletePropertyModel getProperty:[self propertyNameFromTag:LeftRotation]]]];
    [rightRotation setSelectedSegmentIndex:[self rotationControlIndexFromName:[AthletePropertyModel getProperty:[self propertyNameFromTag:RightRotation]]]];
    
}

enum FieldNames
{
    RightVarus = 0,
    LeftVarus = 1,
    RightArch,
    LeftArch,
    RightCollapse,
    LeftCollapse,
    RightRotation,
    LeftRotation,
    RightVarusAngle,
    LeftVarusAngle,
    RightWedges,
    LeftWedges,
};



@end
