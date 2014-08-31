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
#import "AmazonClientManager.h"
#import "BikefitConstants.h"

@interface AthleteInfoController ()

@end

@implementation AthleteInfoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //setup subviews
    infoTableView = [self makeInfoTableView];
    [self.view addSubview: infoTableView];
    [self newAthlete];
    
    //First Name Label Subview
    firstNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(250,150,400,40)];
    [self.view addSubview:firstNameLabel];
    [firstNameLabel setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:36]];
    [firstNameLabel setText:@"First"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadCleanPropertyList];
    [infoTableView reloadData];
    
    //Disable Web Features in online mode is off
    if(![AmazonClientManager verifyUserKey])
    {
        [clientListButton setEnabled:NO];
        [saveToWebButton setEnabled:NO];
    }
    else
    {
        [clientListButton setEnabled:YES];
        [saveToWebButton setEnabled:YES];
        
    }
}

-(UITableView *) makeInfoTableView
{
    CGFloat x = 0;
    CGFloat y = 200;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height - 400;
    CGRect tableFrame = CGRectMake(x, y, width, height);
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];
    
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


-(IBAction) save{
    [AthletePropertyModel saveAthleteToAWS];
}

-(IBAction) newAthlete{
    [AthletePropertyModel newAthlete];
    [self loadCleanPropertyList];
    [infoTableView reloadData];
}

//
//uitableview delegate and data source methods
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"athleteinfocell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    if([indexPath row] == [propertyNames count])
    {
        cell.textLabel.text = @"Add New";
        cell.detailTextLabel.text = @"Tap to add a new field";
        cell.imageView.image = [UIImage imageNamed:@"plus-icon.png"];
        return cell;
    }
    
    NSString *propertyName = [propertyNames objectAtIndex:[indexPath row]];
    cell.textLabel.text = propertyName;
    NSObject *property = [AthletePropertyModel getProperty:propertyName];
    
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
    return [propertyNames count] + 1;
}

- (void) triggerClientListSeque:(id)sender
{
    [self performSegueWithIdentifier:@"clientlistsegue" sender:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self constructInputViewForIndexPath:indexPath];
    [self.view addSubview:inputView];
    [infoTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) constructInputViewForIndexPath:(NSIndexPath *)indexPath
{
    if(!inputView)
    {
        
        inputView = [[UIView alloc] initWithFrame:self.view.frame];
        inputView.backgroundColor = [UIColor blackColor];
        inputView.alpha = .8;
        
        propertyNameText = [[UITextView alloc] initWithFrame:CGRectMake(
                                                inputView.frame.size.width * .25,
                                                inputView.frame.size.height *.2,
                                                400,
                                                50)];
        propertyNameText.backgroundColor = [UIColor whiteColor];
        propertyNameText.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:24];
        [propertyNameText setDelegate:self];
        
        propertyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(35,150,200,100)];
        propertyNameLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:36];
        propertyNameLabel.textColor = [UIColor whiteColor];
        propertyNameLabel.text = @"Property";
        
        [inputView addSubview:propertyNameLabel];
        [inputView addSubview:propertyNameText];
        
        propertyValueText = [[UITextView alloc] initWithFrame:CGRectMake(inputView.frame.size.width * .25,
                                                                                     inputView.frame.size.height *.3,
                                                                                     400,
                                                                                     400)];
        propertyValueText.backgroundColor = [UIColor whiteColor];
        propertyValueText.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:24];
        [propertyValueText setDelegate:self];
        
        propertyValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(50,225,200,100)];
        propertyValueLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:36];
        propertyValueLabel.textColor = [UIColor whiteColor];
        propertyValueLabel.text = @"Value";
        
        [inputView addSubview:propertyValueText];
        [inputView addSubview:propertyValueLabel];
        
        UIButton *savePropertyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        savePropertyButton.frame = CGRectMake(0,0,100,200);
        [savePropertyButton setTitle:@"Done" forState:UIControlStateNormal];
        savePropertyButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:24];
        [savePropertyButton addTarget:self action:@selector(hideInputView) forControlEvents:UIControlEventTouchUpInside];
        [inputView addSubview:savePropertyButton];
        
        inputViewMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(inputView.frame.size.width * .20,
                                                                          inputView.frame.size.height *.01,
                                                                          500,100)];
        inputViewMessageLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:36];
        inputViewMessageLabel.textColor = [UIColor whiteColor];
        [inputView addSubview:inputViewMessageLabel];
    }
    
    if([indexPath row] != [propertyNames count])
    {
        propertyNameText.text = [propertyNames objectAtIndex:[indexPath row]];
        propertyNameText.editable = false;
        propertyValueText.text = [AthletePropertyModel getProperty:[propertyNames objectAtIndex:[indexPath row]]];
        
        inputViewMessageLabel.text = @"Edit Property Value Below";

    }
    else
    {
        inputViewMessageLabel.text = @"Add a New Property Below";
        
        propertyNameText.text = @"";
        propertyValueText.text = @"";
    }
    

}

- (void) hideInputView
{
    [inputView removeFromSuperview];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if( textView == propertyNameText || textView == propertyValueText)
    {
        [AthletePropertyModel setProperty:propertyNameText.text value:propertyValueText.text];
        [self loadCleanPropertyList];
        [infoTableView reloadData];
    }

}

//removes hidden properties from propertlist
- (void) loadCleanPropertyList
{
    propertyNames = [NSMutableArray arrayWithObjects:@"FirstName",@"LastName",@"Email", nil];
    NSArray *hiddenProperties = [NSArray arrayWithObjects:
                        @"FitterName",
                        @"LeftNotes",
                        @"RightNotes",
                        @"DateUpdated",
                        @"FitterEmail",
                        @"FitID",
                        @"fitter",
                        //Default properties
                         @"FirstName",
                         @"LastName",
                         @"Email",
                        nil];
    
    NSArray *uncleanPropertyNames = [AthletePropertyModel propertyNames];
    
    for(NSString *name in uncleanPropertyNames)
    {
        if([hiddenProperties indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            NSString * stringObj = obj;
            return [stringObj isEqualToString:name];
        }] == NSNotFound)
        {
            [propertyNames addObject:name];
        }
    }
    
    
    //Set Name Label text
    NSString *firstNameString = [AthletePropertyModel getProperty:@"FirstName"];
    NSString *lastNameString = [AthletePropertyModel getProperty:@"LastName"];
    NSString *nameString = @"";
    
    if(firstNameString)
    {
        nameString = [nameString stringByAppendingString:firstNameString];
    }
    if(lastNameString)
    {
        nameString = [nameString stringByAppendingString:[NSString stringWithFormat:@" %@",lastNameString]];
    }
    
    if([nameString length] > 1 )
    {
        firstNameLabel.text = nameString;
    }
    else
    {
        firstNameLabel.text = @"Add Name Below";
    }
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






@end
