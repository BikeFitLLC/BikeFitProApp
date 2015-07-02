//
//  AthleteInfoTableCell.h
//  bikefit
//
//  Created by Alfonso Lopez on 6/24/15.
//  Copyright (c) 2015 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AthleteInfoTableCell : UITableViewCell

@property UITextField *titleField;
@property UITextField *textField;
@property BOOL isNewPropertyCell;

- (void) updateAthleteProperty;
@end