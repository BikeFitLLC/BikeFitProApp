//
//  FirstViewController.h
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 5/31/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface AthleteInfoController : UIViewController <UITableViewDataSource,
                                                        UITableViewDelegate,
                                                        UITextViewDelegate,
                                                        MFMailComposeViewControllerDelegate>
{

    NSMutableArray *propertyNames;
    UITableView *infoTableView;
    
    UILabel *firstNameLabel;
    UILabel *lastNameLabel;
    UILabel *emailLabel;
    UIButton *urlButton;
    UIButton *emailFitButton;
    
    UIView *inputView;
    UITextView *propertyNameText;
    UILabel *propertyNameLabel;
    UITextView *propertyValueText;
    UILabel *propertyValueLabel;
    
    UILabel *inputViewMessageLabel;
    
    IBOutlet UIBarButtonItem *clientListButton;
    IBOutlet UIBarButtonItem *saveToWebButton;
    IBOutlet UIButton *saveButton;
    
    MFMailComposeViewController* emailController;
}
-(IBAction) save;
-(IBAction) newAthlete;
//-(IBAction) moveView:(id)sender;
@end
