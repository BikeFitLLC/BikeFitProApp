//
//  FirstViewController.h
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 5/31/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AthleteInfoController : UIViewController <UITextViewDelegate, UITableViewDataSource,
                                                        UITableViewDelegate, UITextViewDelegate>
{

    NSMutableArray *propertyNames;
    UITableView *infoTableView;
    
    UILabel *firstNameLabel;
    UILabel *lastNameLabel;
    UILabel *emailLabel;
    
    UIView *inputView;
    UITextView *propertyNameText;
    UILabel *propertyNameLabel;
    UITextView *propertyValueText;
    UILabel *propertyValueLabel;
    
    UILabel *inputViewMessageLabel;
    
    IBOutlet UIBarButtonItem *clientListButton;
    IBOutlet UIBarButtonItem *saveToWebButton;
    IBOutlet UIButton *saveButton;
}
-(IBAction) save;
-(IBAction) newAthlete;
//-(IBAction) moveView:(id)sender;
@end
