//
//  SideViewViewController.h
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 5/31/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideViewViewController : UIViewController{
    IBOutlet UISegmentedControl *foreAftControl;
    IBOutlet UITextField *legAngleBeforeField;
    IBOutlet UITextField *legAngleAfterField;
    IBOutlet UITextField *saddleChange;
    
     IBOutlet UIImageView *savedImageView;
    
}
-(IBAction) onTextFieldChanged: (id) field;
-(IBAction) onButtonFieldChanged:(UIButton*) button;
//-(IBAction) onLegAngleTouched:(id)sender; //todo remove
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
//- (void) onForeAftChanged;

@end
