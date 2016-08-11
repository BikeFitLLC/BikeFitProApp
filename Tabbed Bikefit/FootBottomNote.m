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
    NSString *imageName = [NSString stringWithFormat:@"%ld_foot_pressure_bw.png", self.footPressure];
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.text = @"Center of Pressure";
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
