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
    
    if(!deleteButton)
    {
        deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        deleteButton.frame = CGRectMake(0,0, 25, 25);
        deleteButton.center = CGPointMake(self.contentView.frame.size.width - 30, self.contentView.frame.size.height/2);
        deleteButton.alpha = .1;
        deleteButton.titleLabel.font = [UIFont systemFontOfSize:24];
        [deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [deleteButton setTitle:@"X" forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(enableDeleting:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:deleteButton];
    }

    if(!deleteButtonEnabled)
    {
        deleteButtonEnabled = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    }
    [deleteButtonEnabled setBackgroundColor:[UIColor redColor]];
    [deleteButtonEnabled setAlpha:1.0];
    [deleteButtonEnabled setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleteButtonEnabled setTitle:@"DELETE" forState:UIControlStateNormal];
    [deleteButtonEnabled sizeToFit];
    deleteButtonEnabled.center = CGPointMake(self.contentView.frame.size.width - 60, self.contentView.superview.frame.size.height/2);
    deleteButtonEnabled.hidden = true;
    [deleteButtonEnabled addTarget:self action:@selector(deleteSelf:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:deleteButtonEnabled];
        
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    self.deleteEnabled = false;
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
