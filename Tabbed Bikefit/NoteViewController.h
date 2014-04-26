//
//  NoteViewController.h
//  bikefit
//
//  Created by Alfonso Lopez on 2/26/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BikeInfoViewController.h"

@interface NoteViewController : UIViewController
{
    BikeInfoViewController * bikeInfo;
}
@property BikeInfoViewController *bikeInfo;

@end
