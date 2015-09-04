//
//  AthletePickerViewController.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 9/30/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "AthletePickerViewController.h"
#import "AthletePropertyModel.h"
#import "BikefitConstants.h"
#import "LoadinSpinnerView.h"

@interface AthletePickerViewController (){
    NSMutableDictionary *fits;
    NSArray *fitIds;
}

@end

@implementation AthletePickerViewController

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
    athleteTableView = [[UITableView alloc] init];
    athleteTableView.frame = self.view.frame;
    [athleteTableView setDataSource:self];
    [athleteTableView setDelegate:self];
    //[athleteTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"athletecell"];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0., 0., 320., 44.)];
    [searchBar setDelegate:self];
    athleteTableView.tableHeaderView = searchBar;
    
    [self.view addSubview:athleteTableView];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //put up loading view before getting athletes
    LoadinSpinnerView *loadingView = [[LoadinSpinnerView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:loadingView];
    [[AthletePropertyModel getAthletesFromAws] continueWithBlock:^id(BFTask *task)
    {
        fits = [AthletePropertyModel fits];
        fitIds = [self sortedFitIdsFromFits:fits];
        [athleteTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [loadingView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        return nil;
    }];

    return;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated { //Implement this method
    [super setEditing:editing animated:animated];
    [athleteTableView setEditing:editing animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *) sortedFitIdsFromFits:(NSDictionary *)fitDict
{
    return [fitDict keysSortedByValueUsingComparator: ^(id obj1, id obj2){
        float date1 = [[(NSDictionary *)obj1 objectForKey:AWS_FIT_ATTRIBUTE_LASTUPDATED] floatValue];
        float date2 = [[(NSDictionary *)obj2 objectForKey:AWS_FIT_ATTRIBUTE_LASTUPDATED] floatValue];
        
        if (date1 < date2)
        {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if(date2 < date1)
        {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return NSOrderedSame;
    }];
}

- (IBAction) close
{
    
}

- (IBAction) editTable
{
    [athleteTableView setEditing:true];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [fitIds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"athletecell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSString *fitid = [fitIds objectAtIndex:[indexPath row]];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ - %@",
                           [[fits objectForKey:fitid] objectForKey:AWS_FIT_ATTRIBUTE_FIRSTNAME],
                           [[fits objectForKey:fitid] objectForKey:AWS_FIT_ATTRIBUTE_LASTNAME],
                           [[fits objectForKey:fitid] objectForKey:AWS_FIT_ATTRIBUTE_EMAIL]];
    
    NSString *unixTimeString = [[fits objectForKey:fitid] objectForKey:AWS_FIT_ATTRIBUTE_LASTUPDATED];
    NSTimeInterval unixTime = [unixTimeString doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTime];
    NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    NSString *dateString = [formatter stringFromDate:date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", dateString ];
    
    if([[fits objectForKey:fitid] objectForKey:FIT_ATTRIBUTE_FROMFILESYSTEM])
    {
        cell.backgroundColor = [UIColor redColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath { //implement the delegate method
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *fitId = [fitIds objectAtIndex:[indexPath row]];
        [AthletePropertyModel removeAthleteFromAWS:fitId];
        
        [fits removeObjectForKey:fitId];
        fitIds = [self sortedFitIdsFromFits:fits];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSString *key =  [fitIds objectAtIndex:[indexPath row]];
    
    LoadinSpinnerView *loadingView = [[LoadinSpinnerView alloc] initWithFrame:self.parentViewController.view.frame];
    [self.view addSubview:loadingView];
    [[AthletePropertyModel loadAthleteFromAWS:key]
     continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task)
     {
         [self performSegueWithIdentifier:@"showfithome" sender:self];
         //[self.navigationController popViewControllerAnimated:YES];
         [loadingView removeFromSuperview];
         return nil;
     }];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

//
// UISearchBar Delegate methods
//
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterFitIdsWithString:searchText];
    [athleteTableView reloadData];
    return;
}

- (void) filterFitIdsWithString:(NSString*)filter
{
    if([filter isEqualToString:@""])
    {
        fitIds = [self sortedFitIdsFromFits:fits];
        return;
    }
    NSMutableArray *filteredFits = [[NSMutableArray alloc] init];
    for( NSString* key in fits)
    {
        NSString *firstName = [[fits objectForKey:key] objectForKey:AWS_FIT_ATTRIBUTE_FIRSTNAME];
        if([firstName containsString:filter])
        {
            [filteredFits addObject:key];
        }
    }
    fitIds = filteredFits;
}

@end
