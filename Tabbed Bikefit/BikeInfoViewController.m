//
//  BikeInfoViewController.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 10/20/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import "BikeInfoViewController.h"
#import "AthletePropertyModel.h"
#import "FitNote.h"
#import "AngleNote.h"
#import "KneeViewNote.h"
#import "FootBottomNote.h"
#import "VarusNote.h"
#import "KopsNote.h"

#import "TextFitNoteViewController.h"
#import "AngleFinderViewController.h"
#import "KneeViewController.h"
#import "FootBottomNoteViewController.h"
#import "VarusNoteViewController.h"
#import "SpindleNoteViewController.h"
#import "ShoulderAngleViewController.h"
#import "KopsViewController.h"
#import "ImageViewerViewController.h"
#import "AngleImageViewerViewController.h"


@interface BikeInfoViewController ()
{
    NSMutableArray *leftNotes; //This holds an ordered list of adjustments made and measurments taken
    NSMutableArray *rightNotes; //This holds an ordered list of adjustments made and measurments taken
    
    NSMutableArray *selectedNotes; //points the most recently selected array of notes
    NSIndexPath *selectedIndexPath; //index to most recently selected table cell
}

@end

@implementation BikeInfoViewController

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
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    if(!(leftNotes = [AthletePropertyModel getProperty:@"LeftNotes"]))
    {
        leftNotes = [[NSMutableArray alloc]init];
    }
    if(!(rightNotes = [AthletePropertyModel getProperty:@"RightNotes"]))
    {
        rightNotes = [[NSMutableArray alloc]init];
    }
    [leftNotesTable setDataSource:self];
    [leftNotesTable setDelegate:self];
    
    [rightNotesTable setDataSource:self];
    [rightNotesTable setDelegate:self];
    
    NSUInteger indexes[] = {0,[leftNotes count]};
    NSIndexPath *leftpath =[[NSIndexPath alloc] initWithIndexes:indexes length:2];
    NSArray * leftpaths = [[NSArray alloc] initWithObjects:leftpath, nil];
    
    [leftNotesTable reloadData];
    [leftNotesTable beginUpdates];
    [leftNotesTable reloadRowsAtIndexPaths:leftpaths withRowAnimation:UITableViewRowAnimationFade];
    [leftNotesTable endUpdates];
    
    NSUInteger rightindexes[] = {0,[rightNotes count]};
    NSIndexPath *rightpath =[[NSIndexPath alloc] initWithIndexes:rightindexes length:2];
    NSArray * rightpaths = [[NSArray alloc] initWithObjects:rightpath, nil];
    
    [rightNotesTable reloadData];
    [rightNotesTable beginUpdates];
    [rightNotesTable reloadRowsAtIndexPaths:rightpaths withRowAnimation:UITableViewRowAnimationFade];
    [rightNotesTable endUpdates];

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == leftNotesTable)
    {
        // Return the number of rows in the section.
        return [leftNotes count] + 1;
    }
    
    else{
        return [rightNotes count] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"measurementCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if( tableView == leftNotesTable)
    {
        if( [indexPath row] == [leftNotes count])
        {
            cell.imageView.image = nil;
            cell.textLabel.text = @"Tap To Add Note";
        }
        else
        {
            [[leftNotes objectAtIndex:[indexPath row]] populateTableCell:cell];
        }
    }
    else
    {
        if( [indexPath row] == [rightNotes count])
        {
            cell.imageView.image = nil;
            cell.textLabel.text = @"Tap To Add Note";
        }
        else
        {
            [[rightNotes objectAtIndex:[indexPath row]] populateTableCell:cell];
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [UIView new];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*save the index path for segue use TODO: i don't know if I like this method*/
    selectedIndexPath = indexPath;
    
    /*figur out which column (left leg notes, or right leg notes) was chose*/
    if(tableView == leftNotesTable)
    {
        selectedNotes = leftNotes;
    }
    else
    {
        selectedNotes = rightNotes;
    }
    
 
    if([indexPath row] >= [selectedNotes count])
    {
        /*if the user selected the table cell at the end of the notes, open a dialog to
         start a new note
         */
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Note Type" delegate:self
                                        cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                        otherButtonTitles:
                                            @"Pedal Spindle Fore/Aft Note",
                                            @"Cleat Medial/Lateral Note",
                                            @"Forefoot Varus Tilt",
                                            @"Text Note",
                                            @"Knee Angle",
                                            @"Shoulder Angle",
                                            @"Foot Pressure",
                                            @"Knee Over Pedal Spindle",
                                      nil];
        [actionSheet showInView:self.view];
    }
    else if( [[selectedNotes objectAtIndex:[indexPath row]] isKindOfClass:[KopsNote class]])
    {
        [self performSegueWithIdentifier:@"ViewKopsNote" sender:self];
    }
    else if( [[selectedNotes objectAtIndex:[indexPath row]] isKindOfClass:[KneeViewNote class]])
    {
        /*if the selected table cell slected contains a note, display it.*/
        [self performSegueWithIdentifier:@"ViewKneeNote" sender:self];
    }
    else if( [[selectedNotes objectAtIndex:[indexPath row]] isKindOfClass:[AngleNote class]])
    {
        [self performSegueWithIdentifier:@"ViewAngleNote" sender:self];
    }
    else if( [[selectedNotes objectAtIndex:[indexPath row]] isKindOfClass:[VarusNote class]])
    {
        [self performSegueWithIdentifier:@"ViewVarusNote" sender:self];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView == leftNotesTable)
    {
        return @"Left Side Notes";
    }
    else if(tableView == rightNotesTable)
    {
        return @"Right Side Notes";
    }
    
    return @"Error";
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *segueIdentifier = @"";
    switch (buttonIndex)
    {
        case 0:
            segueIdentifier = @"addspindlenotesegue";
            break;
        case 1:
            segueIdentifier = @"addkneenotesegue";
            break;
        case 2:
            segueIdentifier = @"addvarusnotesegue";
            break;
        case 3:
            segueIdentifier = @"addtextnotesegue";
            break;
        case 4:
            segueIdentifier = @"addanglenotesegue";
            break;
        case 5:
            segueIdentifier = @"addshoulderanglesegue";
            break;
        case 6:
            segueIdentifier = @"addfootnotesegue";
            break;
        case 7:
            segueIdentifier = @"addkopsnotesegue";
            break;
    }
    if(![segueIdentifier isEqualToString:@""])
    {
        [self performSegueWithIdentifier:segueIdentifier sender:self];
    }
}
- (void) addNote:(FitNote*)note
{
    [selectedNotes addObject:note];
    [AthletePropertyModel setProperty:@"LeftNotes" value:leftNotes];
    [AthletePropertyModel setProperty:@"RightNotes" value:rightNotes];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSString *ident = [segue identifier];
    // Make sure your segue name in storyboard is the same as this line
    if ([ident isEqualToString:@"addtextnotesegue"])
    {
        // Get reference to the destination view controller
        TextFitNoteViewController *vc = [segue destinationViewController];
        [vc setBikeInfo:self];
    }
    else if([ident isEqualToString:@"addanglenotesegue"])
    {
        AngleFinderViewController *vc =  [segue destinationViewController];
        [vc setBikeInfo:self];
    }
    else if([ident isEqualToString:@"addshoulderanglesegue"])
    {
        ShoulderAngleViewController *vc =  [segue destinationViewController];
        [vc setBikeInfo:self];
    }
    else if([ident isEqualToString:@"addkneenotesegue"])
    {
        KneeViewController * vc = [segue destinationViewController];
        [vc setBikeInfo:self];
    }
    else if([ident isEqualToString:@"addfootnotesegue"])
    {
        FootBottomNoteViewController *vc = [segue destinationViewController];
        [vc setBikeInfo:self];
    }
    else if([ident isEqualToString:@"addvarusnotesegue"])
    {
        VarusNoteViewController *vc = [segue destinationViewController];
        [vc setBikeInfo:self];
    }
    else if([ident isEqualToString:@"addspindlenotesegue"])
    {
        SpindleNoteViewController *vc = [segue destinationViewController];
        [vc setBikeInfo:self];
    }
    else if([ident isEqualToString:@"addkopsnotesegue"])
    {
        KopsViewController *vc = [segue destinationViewController];
        [vc setBikeInfo:self];
    }
    else if([ident isEqualToString:@"ViewKneeNote"])
    {
        VideoNoteViewController *vc = [segue destinationViewController];
        KneeViewNote *noteToView = [selectedNotes objectAtIndex:[selectedIndexPath row]];
        [vc setVideoUrl:[noteToView getVideoUrl]];
        [vc setOverlayPath:[noteToView path]];
    }
    else if([ident isEqualToString:@"ViewAngleNote"])
    {
        AngleImageViewerViewController *vc = [segue destinationViewController];
        AngleNote *noteToView = [selectedNotes objectAtIndex:[selectedIndexPath row]];
        
        [vc setImage:[UIImage imageWithData:[noteToView getImage]]];
        [vc setVertices:[noteToView vertices]];
    }
    else if([ident isEqualToString:@"ViewVarusNote"])
    {
        ImageViewerViewController *vc = [segue destinationViewController];
        VarusNote *noteToView = [selectedNotes objectAtIndex:[selectedIndexPath row]];

        [vc setImage:[UIImage imageWithData:[noteToView getImage]]];

    }
    else if([ident isEqualToString:@"ViewKopsNote"])
    {
        ImageViewerViewController *vc = [segue destinationViewController];
        KopsNote *noteToView = [selectedNotes objectAtIndex:[selectedIndexPath row]];
    
        [vc setOverlayPath:[noteToView path]];
        [vc setImage:[UIImage imageWithData:[noteToView getImage]]];
    }
}

@end
