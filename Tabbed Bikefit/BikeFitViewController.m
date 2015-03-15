//
//  BikeInfoViewController.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 10/20/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import "BikeFitViewController.h"
#import "AthletePropertyModel.h"
#import "FitNote.h"
#import "AngleNote.h"
#import "KneeViewNote.h"
#import "FootBottomNote.h"
#import "VarusNote.h"
#import "KopsNote.h"

#import "TextFitNoteViewController.h"
#import "GoniometerViewController.h"
#import "KneeViewController.h"
#import "FootBottomNoteViewController.h"
#import "VarusNoteViewController.h"
#import "SpindleNoteViewController.h"
#import "ShoulderAngleViewController.h"
#import "KopsViewController.h"
#import "ImageViewerViewController.h"
#import "AngleImageViewerViewController.h"
#import "VarusViewerViewController.h"
#import "BikeFitTableViewCell.h"


@interface BikeFitViewController ()
{
    NSMutableArray *leftNotes; //This holds an ordered list of adjustments made and measurments taken
    NSMutableArray *rightNotes; //This holds an ordered list of adjustments made and measurments taken
    
    NSMutableArray *selectedNotes; //points the most recently selected array of notes
    NSIndexPath *selectedIndexPath; //index to most recently selected table cell
}

@end

@implementation BikeFitViewController

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
    UIImageView *cyclistImage = [[UIImageView alloc] init];
    cyclistImage.frame = CGRectMake(
                                 0,
                                 0,
                                 self.view.frame.size.width,
                                 self.view.frame.size.height);
    cyclistImage.alpha = .1;
    cyclistImage.image = [UIImage imageNamed:@"KW_front_laser_2.png"];
    [self.view addSubview:cyclistImage];

    
    
	// Do any additional setup after loading the view.
    rightNotesTable = [[UITableView alloc] init];
    rightNotesTable.frame = CGRectMake(0,0,
                                       self.view.frame.size.width *.5,
                                       self.view.frame.size.height *.8);
    rightNotesTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:rightNotesTable];
    
    // Do any additional setup after loading the view.
    leftNotesTable = [[UITableView alloc] init];
    leftNotesTable.frame = CGRectMake(self.view.frame.size.width *.5,
                                       0,
                                       self.view.frame.size.width *.5,
                                       self.view.frame.size.height *.8);
    leftNotesTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:leftNotesTable];

    [leftNotesTable registerClass:[BikeFitTableViewCell class] forCellReuseIdentifier:@"measurementCell"];
    [rightNotesTable registerClass:[BikeFitTableViewCell class] forCellReuseIdentifier:@"measurementCell"];
    [leftNotesTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"addCell"];
    [rightNotesTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"addCell"];
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

- (void)viewDidAppear:(BOOL)animated
{
    
    [leftNotesTable
        scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[leftNotes count] inSection:0]
        atScrollPosition:UITableViewScrollPositionBottom
        animated:YES
     ];
    [rightNotesTable
     scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[rightNotes count] inSection:0]
     atScrollPosition:UITableViewScrollPositionBottom
     animated:YES
     ];
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
    if( tableView == leftNotesTable)
    {
        if( [indexPath row] == [leftNotes count])
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addCell" forIndexPath:indexPath];
            cell.imageView.image = nil;
            cell.textLabel.text = @"Tap To Add Note";
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
        else
        {
            BikeFitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"measurementCell" forIndexPath:indexPath];
            [[leftNotes objectAtIndex:[indexPath row]] populateTableCell:cell];
            [cell setDelegate:self];
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [UIView new];
            return cell;
        }
    }
    else
    {
        if( [indexPath row] == [rightNotes count])
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addCell" forIndexPath:indexPath];
            cell.imageView.image = nil;
            cell.textLabel.text = @"Tap To Add Note";
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
        else
        {
            BikeFitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"measurementCell" forIndexPath:indexPath];
            [[rightNotes objectAtIndex:[indexPath row]] populateTableCell:cell];
            [cell setDelegate:self];
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [UIView new];
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.frame.size.height *.1;
}

- (void)deleteNoteForCell:(BikeFitTableViewCell*)cell;
{
    
    NSIndexPath *cellPath = [rightNotesTable indexPathForCell:cell];
    NSMutableArray *notes = rightNotes;
    if(!cellPath)
    {
        //is this cell wasn't in the rightnotestable, check the left
        cellPath = [leftNotesTable indexPathForCell:cell];
        notes = leftNotes;
    }
    if(cellPath)
    {
        [notes removeObjectAtIndex:[cellPath row]];
        [rightNotesTable reloadData];
        [leftNotesTable reloadData];
    }
    return;
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
                                            @"Text Note",
                                            @"Goniometer",
                                            @"Saddle Fore/Aft",
                                            @"Cleat Fore/Aft",
                                            @"Cleat Medial/Lateral (Stance width)",
                                            @"Foot Tilt",
                                            @"Foot Pressure",
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
            segueIdentifier = @"addtextnotesegue";
            break;
        case 1:
            segueIdentifier = @"addanglenotesegue";
            break;
        case 2:
            segueIdentifier = @"addkopsnotesegue";
            break;
        case 3:
            segueIdentifier = @"addspindlenotesegue";
            break;
        case 4:
            segueIdentifier = @"addkneenotesegue";
            break;
        case 5:
            segueIdentifier = @"addvarusnotesegue";
            break;
        case 6:
            segueIdentifier = @"addfootnotesegue";
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

///////////////////////////////////////////////////////////////////////
//returns whether or no the currenetly selected column is for left side notes
//if false then the right side notes are selected
////////////////////////////////////////////////////////////////////////
- (bool) leftNotesSelected
{
    return selectedNotes == leftNotes;
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
        GoniometerViewController *vc =  [segue destinationViewController];
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
        [vc setKneeVertices:noteToView.kneeVertices];
        [vc setShoulderVertices:noteToView.shoulderVertices];
        [vc setHipVertices:noteToView.hipVertices];
        [vc setKneeAngle:[noteToView kneeAngle]];
        [vc setShoulderAngle:[noteToView shoulderAngle]];
        [vc setHipAngle:[noteToView hipAngle]];
        
    }
    else if([ident isEqualToString:@"ViewVarusNote"])
    {
        VarusViewerViewController *vc = [segue destinationViewController];
        VarusNote *noteToView = [selectedNotes objectAtIndex:[selectedIndexPath row]];

        [vc setImage:[UIImage imageWithData:[noteToView getImage]]];
        [vc setOverlayPath:[noteToView path]];
        [vc setVarusAngle:[noteToView angle]];

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
