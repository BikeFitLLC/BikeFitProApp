//
//  ShoulderAngleNote.m
//  bikefit
//
//  Created by Alfonso Lopez on 3/10/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "ShoulderAngleNote.h"

@implementation ShoulderAngleNote

- (UITableViewCell *) populateTableCell:(UITableViewCell *)cell
{
    [super populateTableCell:cell];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %d", labelText, (int)(angle/0.0174532925)];
    return cell;
}

-(NSMutableDictionary *) getDictionary
{
    NSMutableDictionary *dictionary = [super getDictionary];
    return dictionary;
    
}
@end
