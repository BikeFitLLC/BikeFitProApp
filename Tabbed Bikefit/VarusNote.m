//
//  VarusNote.m
//  bikefit
//
//  Created by Alfonso Lopez on 2/24/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "VarusNote.h"

@implementation VarusNote
@synthesize angle;

- (UITableViewCell *) populateTableCell:(UITableViewCell *)cell
{
    cell.textLabel.text = [NSString stringWithFormat:@"Ankle Tilt: %f", angle*57.2957795];
    return cell;
}

#pragma mark - NSCoding support
-(void)encodeWithCoder:(NSCoder*)encoder {
    
    [super encodeWithCoder:encoder];
    [encoder encodeFloat:self.angle forKey:@"angle"];
}

-(id)initWithCoder:(NSCoder*)decoder {
    self.angle = [decoder decodeFloatForKey:@"angle"];

    return [super initWithCoder:decoder];
}

@end
