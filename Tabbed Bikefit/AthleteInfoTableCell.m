//
//  AthleteInfoTableCell.m
//  bikefit
//
//  Created by Alfonso Lopez on 6/24/15.
//  Copyright (c) 2015 Alfonso Lopez. All rights reserved.
//

#import "AthleteInfoTableCell.h"
#import "AthletePropertyModel.h"

@implementation AthleteInfoTableCell
@synthesize textField;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if(editing)
    {
        if(textField == nil)
        {
            textField = [[UITextField alloc] init];
            CGRect frame = self.textLabel.frame;
            frame.size.width = self.contentView.frame.size.width;
            [textField addTarget:self action:@selector(updateAthleteProperty) forControlEvents:UIControlEventEditingChanged];
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.frame = frame;
        }
        [self.textLabel setHidden:YES];
        [self.contentView addSubview:textField];
    }
    else
    {
        if(textField)
        {
            [self.textLabel setHidden:NO];
            [textField removeFromSuperview];
        }
    }
}
    
    
- (void)updateAthleteProperty
{
    [AthletePropertyModel setProperty:self.detailTextLabel.text value:self.textField.text];
}
@end
