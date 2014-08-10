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
}

-(id)initWithCoder:(NSCoder*)decoder {
    self.text = [decoder decodeObjectForKey:@"text"];
    return self;
}
@end
