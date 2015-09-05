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
@synthesize titleField;
@synthesize isNewPropertyCell;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if(editing)
    {
        if(textField == nil)
        {
            textField = [[UITextField alloc] init];
            CGRect frame = self.textLabel.frame;
            frame.size.width = self.contentView.frame.size.width *.9;
            [textField addTarget:self action:@selector(updateAthleteProperty) forControlEvents:UIControlEventEditingChanged];
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.frame = frame;
        }
        
        if(titleField == nil)
        {
            titleField = [[UITextField alloc] init];
            CGRect frame = self.detailTextLabel.frame;
            frame.size.height = self.textLabel.frame.size.height;
            frame.size.width = self.contentView.frame.size.width / 2;
            [titleField addTarget:self action:@selector(updateAthleteProperty) forControlEvents:UIControlEventEditingDidEnd];
            titleField.borderStyle = UITextBorderStyleRoundedRect;
            titleField.frame = frame;
        }
        
        [self.textLabel setHidden:YES];
        self.textField.text = self.textLabel.text;
        [self.contentView addSubview:textField];
        
        if(self.editingStyle == UITableViewCellEditingStyleInsert)
        {
            
            [self.detailTextLabel setHidden:YES];
            [self.contentView addSubview:titleField];
            self.titleField.text = @"";
            self.textField.text = @"";
        }
    }
    else
    {
        if(textField)
        {
            [self.detailTextLabel setHidden:NO];
            [self.textLabel setHidden:NO];
            [textField removeFromSuperview];
            [titleField removeFromSuperview];
        }
    }
}
    
    
- (void)updateAthleteProperty
{
    NSString *propertyName;
    if(self.editingStyle == UITableViewCellEditingStyleInsert)
    {
        propertyName = titleField.text;
    }
    else
    {
        propertyName = self.detailTextLabel.text;
    }
    [AthletePropertyModel setProperty:propertyName value:self.textField.text];
}
@end
