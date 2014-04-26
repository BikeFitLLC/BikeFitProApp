//
//  AthletePickerViewController.h
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 9/30/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AthleteTableViewController.h"

@interface AthletePickerViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *athleteTableView;
}

- (IBAction) close;

@end
