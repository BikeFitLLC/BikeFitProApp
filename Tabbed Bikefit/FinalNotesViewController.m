//
//  FinalNotesViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 9/22/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "FinalNotesViewController.h"
#import "BikeFitNavigationController.h"
#import "BikefitConstants.h"

@implementation FinalNotesViewController
{
    UIView *logInReminder;
    UILabel *loginReminderLabel;
}

- (void) viewDidLoad
{

    UIImage *roadBikeImage = [UIImage imageNamed:@"Bike_road_diagram_ABCD"];
    UIImage *triBikeImage = [UIImage imageNamed:@"Bike_tri_diagram_ABCDEF.png"];
    
    bikeDimensionsImages = [NSArray arrayWithObjects:roadBikeImage, triBikeImage, nil];
    
    bikeDimensionsImageView =  [[UIImageView alloc] initWithFrame:CGRectMake(0,30,
                                                                        self.view.frame.size.width,
                                                                        self.view.frame.size.height *.5 )];
    [self.view addSubview:bikeDimensionsImageView];
    
    [bikeDimensionsImageView setUserInteractionEnabled:YES];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [bikeDimensionsImageView addGestureRecognizer:swipeLeft];
    [bikeDimensionsImageView addGestureRecognizer:swipeRight];
    
    // TODO: Move these field names into a constant
    dimensionsFieldNames1 = [[NSMutableArray alloc] initWithObjects:@"A: Saddle Height",
                                                                    @"B: Saddle Setback",
                                                                    @"C: Cockpit Distance",
                                                                    @"D: Handlebar Drop",
                                                                    @"E: Elbow Pad Drop",
                                                                    @"F: Elbow Pad Distance",
                                                                    @"G: Elbow Pad Width",
                                                                    @"Stack",
                                                                    @"Reach",
                                                                    @"Saddle Tilt",
                                                                    @"Stem Length",
                                                                    @"Stem Angle",
                                                                    @"Crank Length",
                                                                    nil];
    
    // SAME AS dimensionsFieldNames1, but missing E, F, and G options, which are only for
    dimensionsFieldNames2 = [[NSMutableArray alloc] initWithObjects:@"A: Saddle Height",
                            @"B: Saddle Setback",
                            @"C: Cockpit Distance",
                            @"D: Handlebar Drop",
                            @"Stack",
                            @"Reach",
                            @"Saddle Tilt",
                            @"Stem Length",
                            @"Stem Angle",
                            @"Crank Length",
                            nil];
    dimensionsFieldNames = dimensionsFieldNames2;
  
    hardwareFieldNames = [[NSMutableArray alloc] initWithObjects:@"Left Pedal Spacers",
                                                                  @"Right Pedal Spacers",
                                                                  @"Left Foot Wedges",
                                                                  @"Right Foot Wedges",
                                                                  @"Left Leg Length Shimming",
                                                                    @"Right Leg Length Shimming",
                                                                  nil];
    
    fieldNameDict = [[NSMutableDictionary alloc] init];
    [fieldNameDict setObject:@"SaddleHeight" forKey:[dimensionsFieldNames1 objectAtIndex:0]];
    [fieldNameDict setObject:@"SaddleSetback" forKey:[dimensionsFieldNames1 objectAtIndex:1]];
    [fieldNameDict setObject:@"CockpitDistance" forKey:[dimensionsFieldNames1 objectAtIndex:2]];
    [fieldNameDict setObject:@"HandlebarDrop" forKey:[dimensionsFieldNames1 objectAtIndex:3]];
    [fieldNameDict setObject:@"ElbowPadDrop" forKey:[dimensionsFieldNames1 objectAtIndex:4]];
    [fieldNameDict setObject:@"ElbowPadDistance" forKey:[dimensionsFieldNames1 objectAtIndex:5]];
    [fieldNameDict setObject:@"ElbowPadWidth" forKey:[dimensionsFieldNames1 objectAtIndex:6]];
    [fieldNameDict setObject:@"Stack" forKey:[dimensionsFieldNames1 objectAtIndex:7]];
    [fieldNameDict setObject:@"Reach" forKey:[dimensionsFieldNames1 objectAtIndex:8]];
    [fieldNameDict setObject:@"SaddleTilt" forKey:[dimensionsFieldNames1 objectAtIndex:9]];
    [fieldNameDict setObject:@"StemLength" forKey:[dimensionsFieldNames1 objectAtIndex:10]];
    [fieldNameDict setObject:@"StemAngle" forKey:[dimensionsFieldNames1 objectAtIndex:11]];
    [fieldNameDict setObject:@"CrankLength" forKey:[dimensionsFieldNames1 objectAtIndex:12]];
    
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
    if(logInReminder)
    {
        [logInReminder removeFromSuperview];
    }
    
    activeBikeImageIndex = [[AthletePropertyModel getProperty:AWS_FIT_ATTRIBUTE_BIKE_TYPE] intValue];
    bikeDimensionsImageView.image = [bikeDimensionsImages objectAtIndex:activeBikeImageIndex];
    
    [dimensionsTable reloadData];
    
    if(![AmazonClientManager verifyLoggedInActive])
    {
        logInReminder = [[UIView alloc] initWithFrame:self.parentViewController.view.frame];
        logInReminder.backgroundColor = [UIColor blackColor];
        logInReminder.alpha = .9;
        
        loginReminderLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * .5,
                                                                       self.view.frame.size.height * .5,
                                                                       self.view.frame.size.width *.5,
                                                                       self.view.frame.size.height *.3)];
        [loginReminderLabel setCenter:CGPointMake(self.view.frame.size.width * .5,
                                                  self.view.frame.size.height * .5)];
        loginReminderLabel.adjustsFontSizeToFitWidth = true;
        loginReminderLabel.textAlignment = NSTextAlignmentCenter;
        loginReminderLabel.numberOfLines = 2;
        loginReminderLabel.textColor = [UIColor whiteColor];
        loginReminderLabel.text = @"Please Login In Order \n to Use Online Features";
        
        [logInReminder addSubview:loginReminderLabel];
        [self.view addSubview:logInReminder];
    }
}

-(UITableView *) makeDimensionTableView
{
    //UITabBarController *tb = (BikeFitNavigationController *)self.parentViewController;
    CGRect tableFrame = CGRectMake(0,
                                   self.view.frame.size.height *.6,
                                   self.view.frame.size.width,
                                   self.view.frame.size.height * .4 );
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStyleGrouped];
    
    tableView.rowHeight = self.view.frame.size.height *.07;
    tableView.sectionFooterHeight = self.view.frame.size.height *.03;
    tableView.sectionHeaderHeight = self.view.frame.size.height *.03;
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
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
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
    if ([indexPath row] == 9 )
    {
        [self performSegueWithIdentifier:@"saddletiltsegue" sender:self];
        return;
    }
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
    if( [fieldName rangeOfString:@"Wedge"].location != NSNotFound)
    {
                millimeterLabel.text = @"Wedges";

    }
    else if( [fieldName rangeOfString:@"Stem Angle"].location != NSNotFound)
    {
        millimeterLabel.text = @"Degrees";
    }
    else
    {
        millimeterLabel.text = @"Millimeters";
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

- (void)showEFG:(BOOL)show {
    if (show) {
        dimensionsFieldNames = dimensionsFieldNames1;
    }
    else {
        dimensionsFieldNames = dimensionsFieldNames2;
    }
    [dimensionsTable reloadData];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        if(activeBikeImageIndex != [bikeDimensionsImages count] - 1)
        {
            [self showEFG:YES];
            
            activeBikeImageIndex = activeBikeImageIndex + 1;
            [AthletePropertyModel setProperty:AWS_FIT_ATTRIBUTE_BIKE_TYPE value:[NSString stringWithFormat:@"%d",activeBikeImageIndex]];
            [UIView transitionWithView:bikeDimensionsImageView
                              duration:0.4f
                               options:UIViewAnimationOptionTransitionFlipFromRight
                            animations:^{
                                bikeDimensionsImageView.image = [bikeDimensionsImages objectAtIndex:activeBikeImageIndex];
                            } completion:NULL];
        }

        NSLog(@"Left Swipe");
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if(activeBikeImageIndex != 0)
        {
            [self showEFG:NO];

            activeBikeImageIndex = activeBikeImageIndex - 1;
            bikeDimensionsImageView.image = [bikeDimensionsImages objectAtIndex:activeBikeImageIndex];
            [AthletePropertyModel setProperty:AWS_FIT_ATTRIBUTE_BIKE_TYPE value:[NSString stringWithFormat:@"%d",activeBikeImageIndex]];
            
            [UIView transitionWithView:bikeDimensionsImageView
                              duration:0.4f
                               options:UIViewAnimationOptionTransitionFlipFromLeft
                            animations:^{
                                bikeDimensionsImageView.image = [bikeDimensionsImages objectAtIndex:activeBikeImageIndex];
                            } completion:NULL];
        }
        NSLog(@"Right Swipe");
    }
}

@end
