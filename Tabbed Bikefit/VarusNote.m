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
    //tells us if the angle is varus or valgus, based on the sign of it
    NSString *varusValgus;
    
    if(self.leftFoot)
    {
        if(angle > 0)
        {
            varusValgus = @"Varus";
        }
        else
        {
            varusValgus = @"Valgus";
        }
    }
    else
    {
        if(angle > 0)
        {
            varusValgus = @"Valgus";
        }
        else
        {
            varusValgus = @"Varus";
        }
    }
    cell.textLabel.text = [NSString stringWithFormat:@"ForeFoot Tilt: %@ - %d°", varusValgus, (int)fabs(angle*57.2957795)];
    cell.imageView.image = nil;
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

-(NSMutableDictionary *) getDictionary
{
    NSMutableDictionary *dictionary = [super getDictionary];
    [dictionary setObject:[NSNumber numberWithFloat:self.angle] forKey:@"angle"];
    return dictionary;
    
}

@end
