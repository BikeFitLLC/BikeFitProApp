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
    [athleteTableView setDataSource:self];
    [athleteTableView setDelegate:self];
    //fits = [[NSMutableArray alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    [self loadAthleteFileNames:documentsDirectory];
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadAthleteFileNames:(NSString *)path
{
    [[AthletePropertyModel getAthletesFromAws] continueWithBlock:^id(BFTask *task) {
        if(task.error)
        {
            NSLog(@"Error Retrieving Fits %@",[task description]);
            return nil;
        }
        
        fits = [[NSMutableDictionary alloc] init];
        //Now that we have retrieved the fit items from AWS, put them into the dictionary
        for(NSMutableDictionary *athleteItem in [task.result items])
        {
            NSMutableDictionary *athleteAttributes = [[NSMutableDictionary alloc] init];
            for( NSString *key in athleteItem )
            {
                [athleteAttributes setObject:[[athleteItem valueForKey:key] S] forKey:key];
            }
            [fits setObject:athleteAttributes forKey:[[athleteItem valueForKey:AWS_FIT_ATTRIBUTE_FITID] S]];
        }
        
        fitIds = [fits keysSortedByValueUsingComparator: ^(id obj1, id obj2){
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

        //[athleteTableView reloadData];
        [athleteTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        return nil;
    }];
    
    }

- (IBAction) close
{
    NSIndexPath *indexPath = [athleteTableView indexPathForSelectedRow];
    NSString *key =  [fitIds objectAtIndex:[indexPath row]];

    [[AthletePropertyModel loadAthleteFromAWS:key]
        continueWithBlock:^id(BFTask *task)
        {
            [self.navigationController popViewControllerAnimated:YES];
            return nil;
        }];

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
    return [fits count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"name";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *fitid = [fitIds objectAtIndex:[indexPath row]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ - %@",
                           [[fits objectForKey:fitid] objectForKey:AWS_FIT_ATTRIBUTE_FIRSTNAME],
                           [[fits objectForKey:fitid] objectForKey:AWS_FIT_ATTRIBUTE_LASTNAME],
                           [[fits objectForKey:fitid] objectForKey:AWS_FIT_ATTRIBUTE_EMAIL]];
    
    if([[fits objectForKey:fitid] objectForKey:FIT_ATTRIBUTE_FROMFILESYSTEM])
    {
        cell.backgroundColor = [UIColor redColor];
    }
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end
