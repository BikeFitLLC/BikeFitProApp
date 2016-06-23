//
//  FitNote.m
//  bikefit
//
//  Created by Alfonso Lopez on 12/10/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "FitNote.h"

@implementation FitNote
{
     NSOperationQueue* aQueue;
}
@synthesize text;
@synthesize leftFoot;

- (UITableViewCell *) populateTableCell:(UITableViewCell *)cell
{
    cell.textLabel.text = text;
    cell.imageView.image = nil;
    
    return cell;
    
}

#pragma mark - NSCoding support
-(void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:self.text forKey:@"text"];
    [encoder encodeBool:self.leftFoot forKey:@"leftfoot"];
}

-(id)initWithCoder:(NSCoder*)decoder {
    self.text = [decoder decodeObjectForKey:@"text"];
    self.leftFoot = [decoder decodeBoolForKey:@"leftfoot"];
    return self;
}

-(NSMutableDictionary *) getDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    
    [dictionary setObject:[NSNumber numberWithBool:self.leftFoot] forKey:@"leftfoot"];
    if(self.text)
    {
        [dictionary setObject:self.text forKey:@"text"];
    }
    [dictionary setObject:NSStringFromClass(self.class) forKey:@"class"];

    return dictionary;
    
}
@end
