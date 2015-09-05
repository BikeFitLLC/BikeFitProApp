//
//  HomeScreenViewController.h
//  bikefit
//
//  Created by Alfonso Lopez on 8/31/15.
//  Copyright (c) 2015 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface HomeScreenViewController : UIViewController <MFMailComposeViewControllerDelegate>


- (void)loadSignedInUser;

- (void) refreshLoginButtons;

@end
