//
//  LegAngleNote.m
//  bikefit
//
//  Created by Alfonso Lopez on 12/13/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "AngleNote.h"
#import "AmazonClientManager.h"
#import "GlobalOperationQueueManager.h"//queue singleton for uploads to aws

@implementation AngleNote
@synthesize angle;
@synthesize labelText;
@synthesize vertices;


- (UITableViewCell *) populateTableCell:(UITableViewCell *)cell
{
    CGRect rect = CGRectMake(0.0, 0.0, 50.0, 50.0);
    UIGraphicsBeginImageContext(rect.size); //now it's here.
    
    UIBezierPath *bezier = [UIBezierPath bezierPathWithRect:rect];
    CGFloat startx = cosf(angle-1.57079633) * 29;
    CGFloat starty = sinf(angle-1.57079633) * 20;
    
    [bezier moveToPoint:CGPointMake(25 - startx, 25 - starty)];
    [bezier addLineToPoint:CGPointMake(25, 25)];
    [bezier addLineToPoint:CGPointMake(25, 45)];
    [bezier setLineWidth:3.0];
    [bezier setLineJoinStyle:kCGLineJoinBevel];
    [bezier stroke];

    UIImage *angleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsPopContext();
    UIGraphicsEndImageContext();
    cell.imageView.image = angleImage;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %d", labelText, 180 - (int)(angle/0.0174532925)];
    return cell;
}

-(int) angleInDegrees
{
    return (int)(angle/0.0174532925);
}

#pragma mark - NSCoding support
-(void)encodeWithCoder:(NSCoder*)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeFloat:self.angle forKey:@"angle"];
    [encoder encodeObject:self.labelText forKey:@"labelText"];
    [encoder encodeObject:self.vertices forKey:@"vertices"];
    //[encoder encodeObject:self.path forKey:@"path"];
    
}

-(id)initWithCoder:(NSCoder*)decoder {
    self.angle = [decoder decodeFloatForKey:@"angle"];
    self.labelText = [decoder decodeObjectForKey:@"labelText"];
    self.vertices = [decoder decodeObjectForKey:@"vertices"];
    //self.path = [decoder decodeObjectForKey:@"path"];
    
    return [super initWithCoder:decoder];;
}

@end
