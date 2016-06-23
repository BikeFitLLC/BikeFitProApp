//
//  SaddleTiltNote.m
//  bikefit
//
//  Created by Alfonso Lopez on 5/11/15.
//  Copyright (c) 2015 Alfonso Lopez. All rights reserved.
//

#import "SaddleTiltNote.h"

@implementation SaddleTiltNote
@synthesize tiltAngle;

- (UITableViewCell *) populateTableCell:(UITableViewCell *)cell
{
    cell.textLabel.text = [NSString stringWithFormat:@"Saddle Tilt: %.02f°", (90 - tiltAngle)];;
    cell.imageView.image = nil;
    
    return cell;
}

-(NSMutableDictionary *) getDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    
    [dictionary setObject:[NSNumber numberWithBool:self.leftFoot] forKey:@"leftfoot"];
    if(self.tiltAngle)
    {
        [dictionary setValue:[NSNumber numberWithFloat:self.tiltAngle] forKey:@"tiltAngle"];
    }
    [dictionary setObject:NSStringFromClass(self.class) forKey:@"class"];
    
    return dictionary;
    
}

@end