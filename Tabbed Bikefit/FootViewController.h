//
//  FootViewController.h
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 9/27/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FootViewController : UIViewController {
    IBOutlet UIStepper *stepperLeftWedge;
    IBOutlet UIStepper *stepperRightWedge;
    
    IBOutlet UISegmentedControl *leftVarus;
    IBOutlet UITextField *leftVarusAngle;
    IBOutlet UISegmentedControl *rightVarus;
    IBOutlet UITextField *rightVarusAngle;
    IBOutlet UISegmentedControl *rightArch;
    IBOutlet UISegmentedControl *leftArch;
    IBOutlet UISegmentedControl *rightCollapse;
    IBOutlet UISegmentedControl *leftCollapse;
    IBOutlet UISegmentedControl *rightRotation;
    IBOutlet UISegmentedControl *leftRotation;
    
    IBOutlet UILabel *leftWedgesLabel;
    IBOutlet UILabel *rightWedgesLabel;

    
}

-(IBAction) onFieldChanged: (id) sender;
@end
