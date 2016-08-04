//
//  FootBottomNote.m
//  bikefit
//
//  Created by Alfonso Lopez on 12/16/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "FootBottomNote.h"

@implementation FootBottomNote

- (UITableViewCell *) populateTableCell:(UITableViewCell *)cell
{
    cell.imageView.image = nil;
    cell.textLabel.text = [NSString stringWithFormat:@"Center of Pressure: %d", self.footPressure];
    return cell;
    
}

#pragma mark - NSCoding support
-(void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeInteger:self.footPressure forKey:@"footPressure"];
}

-(id)initWithCoder:(NSCoder*)decoder {
    self.footPressure = [decoder decodeIntegerForKey:@"footPressure"];
    return self;
}

@end
