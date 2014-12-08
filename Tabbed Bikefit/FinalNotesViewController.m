//
//  FinalNotesViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 9/22/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "FinalNotesViewController.h"

@implementation FinalNotesViewController

- (void) viewDidLoad
{
    bikeDimensionsImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bike_road_diagram_ABCD"]];
    bikeDimensionsImage.frame = CGRectMake(0,30,750,527);
    [self.view addSubview:bikeDimensionsImage];
    
    dimensionsFieldNames = [[NSMutableArray alloc] initWithObjects:@"A: Saddle Height",
                                                                    @"B: Saddle Setback",
                                                                    @"C: Cockpit Distance",
                                                                    @"D: Handlebar Drop",
                                                                    @"Stack",
                                                                    @"Reach",
                                                                    nil];
    hardwareFieldNames = [[NSMutableArray alloc] initWithObjects:@"Left Pedal Spacers",
                                                                  @"Right Pedal Spacers",
                                                                  @"Left Foot Wedges",
                                                                  @"Right Foot Wedges",
                                                                  @"Left Leg Length Shimming",
                                                                    @"Right Leg Length Shimming",
                                                                  nil];
    
    fieldNameDict = [[NSMutableDictionary alloc] init];
    [fieldNameDict setObject:@"SaddleHeight" forKey:[dimensionsFieldNames objectAtIndex:0]];
    [fieldNameDict setObject:@"SaddleSetback" forKey:[dimensionsFieldNames objectAtIndex:1]];
    [fieldNameDict setObject:@"CockpitDistance" forKey:[dimensionsFieldNames objectAtIndex:2]];
    [fieldNameDict setObject:@"HandlebarDrop" forKey:[dimensionsFieldNames objectAtIndex:3]];
    [fieldNameDict setObject:@"Stack" forKey:[dimensionsFieldNames objectAtIndex:4]];
    [fieldNameDict setObject:@"Reach" forKey:[dimensionsFieldNames objectAtIndex:5]];
    [fieldNameDict setObject:@"LeftPedalSpacers" forKey:[hardwareFieldNames objectAtIndex:0]];
    [fieldNameDict setObject:@"RightPedalSpacers" forKey:[hardwareFieldNames objectAtIndex:1]];
    [fieldNameDict setObject:@"LeftWedges" forKey:[hardwareFieldNames objectAtIndex:2]];
    [fieldNameDict setObject:@"RightWedges" forKey:[hardwareFieldNames objectAtIndex:3]];
    [fieldNameDict setObject:@"LeftShimming" forKey:[hardwareFieldNames objectAtIndex:4]];
    [fieldNameDict setObject:@"RightShimming" forKey:[hardwareFieldNames objectAtIndex:5]];


    dimensionsTable = [self makeDimensionTableView];
    [self.view addSubview:dimensionsTable];

}

- (void)viewWillAppear:(BOOL)animated
{
    [dimensionsTable reloadData];
}

-(UITableView *) makeDimensionTableView
{
    CGFloat x = 0;
    CGFloat y = 600;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = [dimensionsFieldNames count] * 60 + 100;
    CGRect tableFrame = CGRectMake(x, y, width, height);
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStyleGrouped];
    
    tableView.rowHeight = 60;
    tableView.sectionFooterHeight = 22;
    tableView.sectionHeaderHeight = 22;
    tableView.scrollEnabled = YES;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.userInteractionEnabled = YES;
    tableView.bounces = YES;
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    return tableView;
}

//
//uitableview delegate and data source methods
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"athleteinfocell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    else
    {
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
    }
    
    NSString *propertyName;
    if([indexPath section] == 0)
    {
        propertyName = [dimensionsFieldNames objectAtIndex:[indexPath row]];
    }
    else if([indexPath section] == 1)
    {
        propertyName = [hardwareFieldNames objectAtIndex:[indexPath row]];
    }
   
    cell.textLabel.text = propertyName;
    NSObject *property = [AthletePropertyModel getProperty:[fieldNameDict objectForKey:propertyName]];
    
    if([property isKindOfClass:[NSString class]])
    {
        cell.imageView.image = nil;
        NSString *propertyString = (NSString*)property;
        if([propertyString isEqualToString:@""])
        {
            cell.detailTextLabel.text = @"Tap to add";
        }
        else
        {
            cell.detailTextLabel.text = (NSString *)property;
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [dimensionsFieldNames count];
    }
    return [hardwareFieldNames count];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self constructInputViewForIndexPath:indexPath];
    [self.view addSubview:propertyEditView];
    [dimensionsTable deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) constructInputViewForIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sectionArray;
    if([indexPath section] == 0 )
    {
        sectionArray = dimensionsFieldNames;
    }
    else
    {
        sectionArray = hardwareFieldNames;
    }
    
    NSString *fieldName = [sectionArray objectAtIndex:[indexPath row]];
    
    if(!propertyEditView)
    {
        
        propertyEditView = [[UIView alloc] initWithFrame:self.view.frame];
        propertyEditView.backgroundColor = [UIColor blackColor];
        propertyEditView.alpha = .8;
        
        propertyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                        propertyEditView.frame.size.width * .25,
                                                                        propertyEditView.frame.size.height *.2,
                                                                        400,
                                                                        50)];
        propertyNameLabel.textColor = [UIColor whiteColor];
        propertyNameLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:24];
        [propertyEditView addSubview:propertyNameLabel];
        
        propertyValueField = [[UITextField alloc] initWithFrame:CGRectMake(propertyEditView.frame.size.width * .25,
                                                                         propertyEditView.frame.size.height *.3,
                                                                         100,
                                                                         100)];
        propertyValueField.backgroundColor = [UIColor whiteColor];
        propertyValueField.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:24];
        [propertyValueField setDelegate:self];
        [propertyEditView addSubview:propertyValueField];
        
        millimeterLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                                                propertyValueField.frame.origin.x + propertyValueField.frame.size.width + 20,
                                                propertyValueField.frame.origin.y,
                                                  400,
                                                  50)];
        millimeterLabel.textColor = [UIColor whiteColor];
        millimeterLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:24];
            
        
        [propertyEditView addSubview:millimeterLabel];
        
        UIButton *savePropertyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        savePropertyButton.frame = CGRectMake(0,0,100,200);
        [savePropertyButton setTitle:@"Done" forState:UIControlStateNormal];
        savePropertyButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:24];
        [savePropertyButton addTarget:self action:@selector(hideInputView) forControlEvents:UIControlEventTouchUpInside];
        [propertyEditView addSubview:savePropertyButton];
    }
    
    propertyNameLabel.text = fieldName;
    [propertyValueField setText:[AthletePropertyModel getProperty:[fieldNameDict objectForKey:fieldName]]];
    if( [fieldName rangeOfString:@"Wedge"].location == NSNotFound)
    {
        millimeterLabel.text = @"Millimeters";
    }
    else
    {
        millimeterLabel.text = @"Wedges";
    }
    
}

- (void) hideInputView
{
    [propertyEditView removeFromSuperview];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if( textField == propertyValueField )
    {
        [AthletePropertyModel setProperty:[fieldNameDict objectForKey:propertyNameLabel.text] value:propertyValueField.text];
        [dimensionsTable reloadData];
    }
    
}

@end
