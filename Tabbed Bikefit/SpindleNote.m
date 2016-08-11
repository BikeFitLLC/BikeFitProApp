//
//  SpindleNote.m
//  bikefit
//
//  Created by Alfonso Lopez on 2/26/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "SpindleNote.h"

@implementation SpindleNote

- (UITableViewCell *) populateTableCell:(UITableViewCell *)cell
{
    cell.textLabel.text = @"Cleat Fore-Aft";
    
    CGRect rect = CGRectMake(0.0, 0.0, 50.0, 25.0);
    UIGraphicsBeginImageContext(rect.size);
    UIBezierPath *border = [UIBezierPath bezierPathWithRect:rect];
    //Draw a border
    [border setLineWidth:1.0];
    [[UIColor grayColor] setStroke];
    [border stroke];

    UIBezierPath *yPositionPath = [[UIBezierPath alloc]init];

    CGFloat height = 25 * self.yPositionAsPercent;
    [yPositionPath moveToPoint:CGPointMake(0, height)];
    [yPositionPath addLineToPoint:CGPointMake(50, height)];
    [[UIColor blackColor] setStroke];
    [yPositionPath setLineWidth:3.0];
    [yPositionPath stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsPopContext();
    UIGraphicsEndImageContext();
    cell.imageView.image = image;

    return cell;
    
}

#pragma mark - NSCoding support
-(void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeFloat:self.yPositionAsPercent forKey:@"yPos"];
}

-(id)initWithCoder:(NSCoder*)decoder
{
    self.yPositionAsPercent = [decoder decodeFloatForKey:@"yPos"];
    return self;
}

- (NSDictionary *)getDictionary
{
    return [super getDictionary];
}

@end
