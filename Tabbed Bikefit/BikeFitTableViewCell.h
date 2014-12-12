//
//  BikeFitTableViewCell.h
//  bikefit
//
//  Created by Alfonso Lopez on 12/12/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BikeFitTableViewCellDelegate

- (void)deleteNoteForCell:(UITableViewCell*)cell;

@end
@interface BikeFitTableViewCell : UITableViewCell
{
    
}

@property (nonatomic, assign) id <BikeFitTableViewCellDelegate> delegate;
@property UIButton *deleteButton;
@property UIButton *deleteButtonEnabled;
@property bool hideDeleteButton;
@property bool deleteEnabled;
@end


