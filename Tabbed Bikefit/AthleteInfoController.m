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
{
    UIView *logInReminder;
    UILabel *loginReminderLabel;
}

@end

@implementation AthleteInfoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *logoImage = [[UIImageView alloc] init];
    logoImage.frame = CGRectMake(
                                 self.view.frame.size.width * .1,
                                 0,
                                 self.view.frame.size.width *.8,
                                 self.view.frame.size.width *.3);
    logoImage.image = [UIImage imageNamed:@"BikeFit_logo_Horiz.png"];
    [self.view addSubview:logoImage];
    
    //setup subviews
    infoTableView = [self makeInfoTableView];
    [self.view addSubview: infoTableView];
    [self newAthlete];
    
    //First Name Label Subview
    firstNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                                              self.view.frame.size.width * .2,
                                              self.view.frame.size.height * .1,
                                              self.view.frame.size.width *.6,
                                              self.view.frame.size.width *.3)];
    [self.view addSubview:firstNameLabel];
    [firstNameLabel setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:36]];
    firstNameLabel.adjustsFontSizeToFitWidth = YES;
    [firstNameLabel setText:@"First"];
    
    //Create label to display the url for this fit
    urlButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [urlButton setFrame:CGRectMake(
                                   self.view.frame.size.width * .6,
                                   self.view.frame.size.height * .1,
                                   100,
                                   50)];
    [urlButton setTitle:@"View Fit" forState:UIControlStateNormal];
    [urlButton addTarget:self
               action:@selector(openFitUrl)
     forControlEvents:UIControlEventTouchUpInside];
    urlButton.hidden = YES;
    urlButton.enabled = NO;
    [self.view addSubview:urlButton];
    
    //Create label to display the url for this fit
    emailFitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [emailFitButton setFrame:CGRectMake(
                                        self.view.frame.size.width * .1,
                                        self.view.frame.size.height * .1,
                                        100,
                                        50)];
    [emailFitButton setTitle:@"Email Fit" forState:UIControlStateNormal];
    [emailFitButton addTarget:self
                  action:@selector(emailFit)
        forControlEvents:UIControlEventTouchUpInside];
    emailFitButton.hidden = YES;
    emailFitButton.enabled = NO;
    [self.view addSubview:emailFitButton];
    
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
    
    [self updateUrlButtons];
    
    
    if(![AmazonClientManager verifyUserKey])
    {
        logInReminder = [[UIView alloc] initWithFrame:self.view.frame];
        logInReminder.backgroundColor = [UIColor blackColor];
        logInReminder.alpha = .7;
        
        loginReminderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                       0,
                                                                       self.view.frame.size.width *.5,
                                                                       self.view.frame.size.height *.3)];
        loginReminderLabel.adjustsFontSizeToFitWidth = true;
        loginReminderLabel.textColor = [UIColor whiteColor];
        loginReminderLabel.text = @"Please Login In Order to Use Online Features";
        
        [logInReminder addSubview:loginReminderLabel];
        [self.view addSubview:logInReminder];
    }
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
    CGFloat y = self.view.frame.size.height *.3;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = toolbar.frame.origin.y - y;
    CGRect tableFrame = CGRectMake(x, y, width, height);
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];
    
    tableView.rowHeight = self.view.frame.size.height *.07;;
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
        
        inputView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height)];
        inputView.backgroundColor = [UIColor blackColor];
        inputView.alpha = .8;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(dismissKeyboard)];
        
        [self.view addGestureRecognizer:tap];
        
        propertyNameText = [[UITextView alloc] initWithFrame:CGRectMake(
                                                inputView.frame.size.width * .25,
                                                inputView.frame.size.height *.2,
                                                400,
                                                50)];
        propertyNameText.backgroundColor = [UIColor whiteColor];
        propertyNameText.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:24];
        [propertyNameText setDelegate:self];
        
        propertyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                                              inputView.frame.size.width * .25,
                                              inputView.frame.size.height *.1,
                                              inputView.frame.size.width * .6,
                                              inputView.frame.size.height *.2)];
        propertyNameLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:36];
        propertyNameLabel.textColor = [UIColor whiteColor];
        propertyNameLabel.text = @"Property";
        
        [inputView addSubview:propertyNameLabel];
        [inputView addSubview:propertyNameText];
        
        propertyValueText = [[UITextView alloc] initWithFrame:CGRectMake(
                                                               self.view.frame.size.width * .1,
                                                               self.view.frame.size.height * .3,
                                                               self.view.frame.size.width *.8,
                                                               self.view.frame.size.width *.3)];
        propertyValueText.backgroundColor = [UIColor whiteColor];
        propertyValueText.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:24];
        [propertyValueText setDelegate:self];
        
        /*
        propertyValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(50,225,200,100)];
        propertyValueLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:36];
        propertyValueLabel.textColor = [UIColor whiteColor];
        propertyValueLabel.text = @"Value";
        */
        [inputView addSubview:propertyValueText];
        //[inputView addSubview:propertyValueLabel];
        
        UIButton *savePropertyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        savePropertyButton.frame = CGRectMake(
                                              self.view.frame.size.width * .4,
                                              self.view.frame.size.height * .8,
                                              self.view.frame.size.width *.2,
                                              self.view.frame.size.width *.1);
        [savePropertyButton setTitle:@"Done" forState:UIControlStateNormal];
        savePropertyButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:24];
        [savePropertyButton addTarget:self action:@selector(hideInputView) forControlEvents:UIControlEventTouchUpInside];
        [inputView addSubview:savePropertyButton];
        
        inputViewMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                                                             self.view.frame.size.width * .1,
                                                             0,
                                                             self.view.frame.size.width *.8,
                                                             self.view.frame.size.width *.3)];
        
        inputViewMessageLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:36];
        inputViewMessageLabel.adjustsFontSizeToFitWidth = YES;
        inputViewMessageLabel.textColor = [UIColor whiteColor];
        [inputView addSubview:inputViewMessageLabel];
    }
    
    if([indexPath row] != [propertyNames count])
    {
        propertyNameLabel.text = [propertyNames objectAtIndex:[indexPath row]];
        propertyNameText.hidden = YES;
        propertyValueText.text = [AthletePropertyModel getProperty:[propertyNames objectAtIndex:[indexPath row]]];
        
        inputViewMessageLabel.text = @"Edit Property Value Below";

    }
    else
    {
        inputViewMessageLabel.text = @"Add a New Field Below";
        
        propertyNameText.text = @"";
        propertyNameText.hidden = NO;
        propertyNameLabel.text = @"Field";
        ;
        propertyValueText.text = @"";
    }
    

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
                        @"LeftNotes",
                        @"RightNotes",
                        @"DateUpdated",
                        @"FitterEmail",
                        @"FitID",
                        @"fitter",
                        @"LeftNotesJSON",
                        @"RightNotesJSON",
                        @"FitUrl",
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

- (void) openFitUrl
{
    NSString *url = [[AthletePropertyModel getProperty:AWS_FIT_ATTRIBUTE_URL] lowercaseString];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void) emailFit
{
    emailController= [[MFMailComposeViewController alloc] init];
    emailController.mailComposeDelegate = self;
    NSString *fitterName = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTERNAME_KEY];
    NSString *url = [[AthletePropertyModel getProperty:AWS_FIT_ATTRIBUTE_URL] lowercaseString];
    NSString *emailSubject = [NSString stringWithFormat:@"Your Fit from %@",fitterName];
    NSString *emailMessage = [NSString stringWithFormat:@"Thanks for coming in! <br /><br /><a href=\"%@\">Click to view your fit</a>", url];
    
    [emailController setToRecipients:[NSArray arrayWithObject:[AthletePropertyModel getProperty:AWS_FIT_ATTRIBUTE_EMAIL ]]];
    [emailController setSubject:emailSubject];
    [emailController setMessageBody:emailMessage isHTML:YES];
    if (emailController)
    {
        [self presentViewController:emailController animated:YES completion:NULL];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [emailController dismissViewControllerAnimated:YES completion:NULL];
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
