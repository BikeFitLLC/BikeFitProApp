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
    athleteTableView = [[UITableView alloc] init];
    athleteTableView.frame = CGRectMake(0,
                                        0,
                                        self.view.frame.size.width,
                                        self.view.frame.size.height * .6);
    [athleteTableView setDataSource:self];
    [athleteTableView setDelegate:self];
    [athleteTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"athletecell"];
    [self.view addSubview:athleteTableView];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    [self loadAthleteFileNames:documentsDirectory];
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
            if(![athleteItem objectForKey:AWS_FIT_ATTRIBUTE_HIDDEN])
            {
                NSMutableDictionary *athleteAttributes = [[NSMutableDictionary alloc] init];
                for( NSString *key in athleteItem )
                {
                    [athleteAttributes setObject:[[athleteItem valueForKey:key] S] forKey:key];
                }
                [fits setObject:athleteAttributes forKey:[[athleteItem valueForKey:AWS_FIT_ATTRIBUTE_FITID] S]];
            }
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
    return [fits count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"athletecell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *fitid = [fitIds objectAtIndex:[indexPath row]];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath { //implement the delegate method
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [fits removeObjectForKey:[fitIds objectAtIndex:indexPath.row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [AthletePropertyModel removeAthleteFromAWS:[fitIds objectAtIndex:indexPath.row]];
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
    [[AthletePropertyModel loadAthleteFromAWS:key]
     continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task)
     {
         [self.navigationController popViewControllerAnimated:YES];
         return nil;
     }];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}



@end
