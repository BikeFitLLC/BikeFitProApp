//
//  BikeFitTableViewCell.m
//  bikefit
//
//  Created by Alfonso Lopez on 12/12/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "BikeFitTableViewCell.h"

@implementation BikeFitTableViewCell
@synthesize delegate;
@synthesize deleteButton;
@synthesize deleteButtonEnabled;
@synthesize hideDeleteButton;
@synthesize deleteEnabled = _deleteEnabled;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    self.deleteEnabled = false;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
}

-(void)deleteSelf:(id)sender
{
    [delegate deleteNoteForCell:self];
}
-(void)enableDeleting:(id)sender
{
    self.deleteEnabled = true;
}
- (void)setDeleteEnabled:(bool)deleteEnabled
{
    _deleteEnabled = deleteEnabled;
    deleteButtonEnabled.hidden = !deleteEnabled;
    deleteButton.hidden = deleteEnabled;
    
}

-(bool)deleteEnabled
{
    return _deleteEnabled;
}

@end
