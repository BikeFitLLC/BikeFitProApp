//
//  BikeInfoViewController.h
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 10/20/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FitNote.h"

@interface BikeFitViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UIActionSheetDelegate>
{

    IBOutlet UITableView *leftNotesTable;
    IBOutlet UITableView *rightNotesTable;
    
}

- (void) addNote:(FitNote*)note;
- (bool) leftNotesSelected;

@end
