//
//  FirstViewController.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 5/31/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "AthleteInfoController.h"
#import "BikeFitNavigationController.h"
#import "AthletePropertyModel.h"
#import "AmazonClientManager.h"
#import "BikefitConstants.h"
#import "AthleteInfoTableCell.h"
#import "UIColor+CustomColor.h"


@interface AthleteInfoController ()
{
    UIView *logInReminder;
    UILabel *loginReminderLabel;
    bool editing;
    CGRect oldTableFrame;
    
    NSIndexPath *selectionIndexPath;
}

@end

@implementation AthleteInfoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    editing = NO;
    
    UIImageView *logoImage = [[UIImageView alloc] init];
    logoImage.frame = CGRectMake(
                                 self.view.frame.size.width * .1,
                                 0,
                                 self.view.frame.size.width *.65,
                                 self.view.frame.size.width *.15);
    logoImage.center = CGPointMake(self.view.center.x, logoImage.center.y);
    logoImage.image = [UIImage imageNamed:@"BikeFit_logo_Horiz.png"];
    [self.view addSubview:logoImage];
    
    //setup subviews
    //First Name Label Subview
    firstNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                0,
                                                                self.view.frame.size.width *.6,
                                                                self.view.frame.size.width *.1)];
    firstNameLabel.center = CGPointMake(self.view.center.x, logoImage.center.y + logoImage.frame.size.height *.5);
    [self.view addSubview:firstNameLabel];
    [firstNameLabel setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:36]];
    firstNameLabel.textAlignment = NSTextAlignmentCenter;
    firstNameLabel.adjustsFontSizeToFitWidth = YES;
    [firstNameLabel setText:@"First"];
    
    //Create label to display the url for this fit
    urlButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [urlButton setFrame:CGRectMake(0,
                                   firstNameLabel.frame.origin.y + firstNameLabel.frame.size.height,
                                   100,
                                   50)];
    urlButton.center = CGPointMake(self.view.frame.size.width *.25, urlButton.center.y);
    [urlButton setTitle:@"View Fit" forState:UIControlStateNormal];
    [urlButton addTarget:self
               action:@selector(openFitUrl)
     forControlEvents:UIControlEventTouchUpInside];
    urlButton.hidden = YES;
    urlButton.enabled = NO;
    [self.view addSubview:urlButton];
    
    //Create label to display the url for this fit
    emailFitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [emailFitButton setFrame:CGRectMake(0,
                                        firstNameLabel.frame.origin.y + firstNameLabel.frame.size.height,
                                        100,
                                        50)];
    emailFitButton.center = CGPointMake(self.view.frame.size.width *.75, emailFitButton.center.y);
    [emailFitButton setTitle:@"Email Fit" forState:UIControlStateNormal];
    [emailFitButton addTarget:self
                  action:@selector(emailFit)
        forControlEvents:UIControlEventTouchUpInside];
    emailFitButton.hidden = YES;
    emailFitButton.enabled = NO;
    [self.view addSubview:emailFitButton];
    
    infoTableView = [self makeInfoTableView];
    //infoTableView.frame = CGRectMake(0,
    //                                 emailFitButton.frame.origin.y + emailFitButton.frame.size.height,
    //                                 infoTableView.frame.size.width,
    //                                 toolbar.frame.origin.y - emailFitButton.frame.origin.y - emailFitButton.frame.size.height );
    [self.view addSubview: infoTableView];
    
    [firstNameLabel setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:36]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    if(logInReminder)
    {
        [logInReminder removeFromSuperview];
    }
    
    [self loadCleanPropertyList];
    [infoTableView reloadData];
    
    //Disable Web Features in online mode is off
    if(![AmazonClientManager verifyLoggedInActive])
    {
        [clientListButton setEnabled:NO];
        [saveToWebButton setEnabled:NO];
    }
    else
    {
        [clientListButton setEnabled:YES];
        [saveToWebButton setEnabled:YES];
    }
    
    [self updateUrlButtons];
    
    
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

- (void)setEditing:(BOOL)editingInput animated:(BOOL)animated { //Implement this method
    [super setEditing:editingInput animated:animated];
    
    [self loadCleanPropertyList];
    
    editing = editingInput;
    if(editing)
    {
        [propertyNames addObject:@"New Field"];
    }
    else
    {
        NSString *lastFieldName =[propertyNames objectAtIndex:propertyNames.count - 1];
        if( [lastFieldName isEqualToString:@"New Field"])
        {
            [propertyNames removeObjectAtIndex:propertyNames.count - 1];
        }
    }
    [infoTableView reloadData];
    [infoTableView reloadRowsAtIndexPaths:[infoTableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
    [infoTableView setEditing:editing animated:animated];
   

    
}

- (void) updateUrlButtons
{
    NSString *url = [AthletePropertyModel getProperty:AWS_FIT_ATTRIBUTE_URL];
    if(url)
    {
        urlButton.hidden = NO;
        urlButton.enabled = YES;
        
        emailFitButton.hidden = NO;
        emailFitButton.enabled = YES;
    }
    else
    {
        urlButton.hidden = YES;
        urlButton.enabled = NO;
        
        emailFitButton.hidden = YES;
        emailFitButton.enabled = NO;
    }
}


-(UITableView *) makeInfoTableView
{
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height;
    CGRect tableFrame = CGRectMake(x, y, width, height);
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];
    
    tableView.rowHeight = self.view.frame.size.height *.07;
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
    [self updateUrlButtons];
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
    AthleteInfoTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[AthleteInfoTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    if([indexPath row] == [propertyNames count] - 1)
    {
        cell.isNewPropertyCell = YES;
    }
    
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [downloadButton setBackgroundColor:[UIColor bikeFitBlue]];
    [downloadButton setTitle:@"Done" forState:UIControlStateNormal];
    [downloadButton setFrame:CGRectMake(0, 0, 100, 35)];
    [downloadButton addTarget:self action:@selector(endEditing:) forControlEvents:UIControlEventTouchUpInside];
    cell.editingAccessoryView = downloadButton;
    
    
    NSString *propertyName = [propertyNames objectAtIndex:[indexPath row]];
    cell.detailTextLabel.text = propertyName;
    
    NSObject *property = [AthletePropertyModel getProperty:propertyName];
    if([property isKindOfClass:[NSString class]])
    {
        cell.imageView.image = nil;
        NSString *propertyString = (NSString*)property;
        if(editing)
        {
            cell.textField.text = propertyString;
        }
        else if ([propertyString isEqualToString:@""])
        {
            cell.textLabel.text = @"Edit to add";
        }
        else
        {
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.text = propertyString;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < propertyNames.count)
    {
        NSString *propertyValue = [AthletePropertyModel getProperty:[propertyNames objectAtIndex:[indexPath row]]];
        propertyValue = [[propertyValue componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
        NSParagraphStyle *paragraphStyle = [NSParagraphStyle defaultParagraphStyle];
        
        CGSize labelSize =[propertyValue boundingRectWithSize:CGSizeMake(infoTableView.frame.size.width, MAXFLOAT)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{
                                                                       NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:18.0],
                                                                       NSParagraphStyleAttributeName: paragraphStyle
                                                                       }
                                                      context:nil].size;
        
        if( labelSize.height > tableView.rowHeight)
            return labelSize.height * 1.5;
    }
    return tableView.rowHeight ;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == [propertyNames count] - 1)
    {
        return UITableViewCellEditingStyleInsert;
    }

    return UITableViewCellEditingStyleDelete;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [propertyNames count];
}

- (void) triggerClientListSeque:(id)sender
{
    [self performSegueWithIdentifier:@"clientlistsegue" sender:self];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectionIndexPath = indexPath;
    [tableView setEditing:YES];
    [infoTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath { //implement the delegate method
    selectionIndexPath = nil;
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [AthletePropertyModel removeProperty:[propertyNames objectAtIndex:[indexPath row]]];
        [propertyNames removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];


    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        //put code to handle insertion
        //[myTableView reloadData];
    }
    [tableView setEditing:NO];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [tableView setEditing:NO animated:YES];
}

- (void) endEditing: (id) sender
{
    [infoTableView setEditing:NO animated:YES];
    [infoTableView reloadData];
}

-(void)dismissKeyboard {
    [propertyNameText resignFirstResponder];
}

- (void) hideInputView
{
    [inputView removeFromSuperview];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSString *propertyName;
    
    if( textView == propertyNameText)
    {
        propertyName = propertyNameText.text;
    }
    
    if(textView == propertyValueText)
    {
        if(propertyNameText.hidden)
        {
            //use the label for peoperty name
            propertyName = propertyNameLabel.text;
        }
        else
        {
            propertyName = propertyNameText.text;
        }
        
    }
    
    [AthletePropertyModel setProperty:propertyName value:propertyValueText.text];
    [self loadCleanPropertyList];
    [infoTableView reloadData];

}

//removes hidden properties from propertlist
- (void) loadCleanPropertyList
{
    propertyNames = [NSMutableArray arrayWithObjects:@"FirstName",@"LastName",@"Email", nil];
    NSArray *hiddenProperties = [NSArray arrayWithObjects:
                        @"FitterName",
                        @"FitterID",
                        @"LeftNotes",
                        @"RightNotes",
                        @"DateUpdated",
                        @"FitterEmail",
                        @"FitID",
                        @"fitter",
                        @"LeftNotesJSON",
                        @"RightNotesJSON",
                        @"FitUrl",
                        @"BikeType",
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



-(IBAction) keyboardDidShow:(NSNotification*)notification
{
    [infoTableView setContentInset:
        UIEdgeInsetsMake(0.f, 0.f, [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey ] CGRectValue].size.height, 0.f)];
}

-(IBAction) keyboardDidHide:(NSNotification*)notification
{
    [infoTableView setContentInset:UIEdgeInsetsZero];
}









@end
