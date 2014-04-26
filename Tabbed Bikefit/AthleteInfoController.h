//
//  FirstViewController.h
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 5/31/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AthleteInfoController : UIViewController {
    IBOutlet UITextField *firstName;
    IBOutlet UITextField *lastName;
    IBOutlet UITextField *email;
    
    IBOutlet UITextField *address;
    IBOutlet UITextField *bike;
    IBOutlet UITextField *bikeSize;
    IBOutlet UITextField *pedals;
    IBOutlet UITextField *shoes;
    IBOutlet UITextField *milesPerWeek;
    IBOutlet UITextField *yearsCycling;
    IBOutlet UITextField *cyclingType;
    IBOutlet UITextField *saddle;
    IBOutlet UITextView *concerns;


    IBOutlet UIButton *saveButton;
}
-(IBAction) onFieldChanged: (id) sender;
-(IBAction) save;
-(IBAction) newAthlete;
//-(IBAction) moveView:(id)sender;
@end
