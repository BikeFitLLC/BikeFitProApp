//
//  SpindleNote.m
//  bikefit
//
//  Created by Alfonso Lopez on 2/26/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "SpindleNote.h"

@implementation SpindleNote
@synthesize path;

- (UITableViewCell *) populateTableCell:(UITableViewCell *)cell
{
    cell.textLabel.text = @"Cleat Fore-Aft";
    
    CGRect rect = CGRectMake(0.0, 0.0, 50.0, 50.0);
    
    UIBezierPath *border = [UIBezierPath bezierPathWithRect:rect];
    //Draw a border
    [border setLineWidth:3.0];
    [border setLineJoinStyle:kCGLineJoinBevel];
    [border stroke];

    UIGraphicsBeginImageContext(rect.size);
    UIBezierPath *scaledPath = [[UIBezierPath alloc]init];
    
    //Set the scale we will transorm too
    CGFloat scaleX = .05;
    CGFloat scaleY = .13;
    
    CGAffineTransform transform = CGAffineTransformMakeScale(scaleX, scaleY);
    CGAffineTransform translation = CGAffineTransformMakeTranslation(100, -300);

    
    //Move the path to the right
    CGPathRef intermediatePath = CGPathCreateCopyByTransformingPath(path.CGPath, &translation);
    scaledPath.CGPath = intermediatePath;

    intermediatePath = CGPathCreateCopyByTransformingPath(scaledPath.CGPath, &transform);
    scaledPath.CGPath = intermediatePath;
    
    [scaledPath setLineWidth:3.0];
    [scaledPath setLineJoinStyle:kCGLineJoinBevel];
    [scaledPath stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsPopContext();
    UIGraphicsEndImageContext();
    cell.imageView.image = image;
    
    //append the foot box path
    
    return cell;
    
}

#pragma mark - NSCoding support
-(void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:self.path forKey:@"path"];
}

-(id)initWithCoder:(NSCoder*)decoder
{
    self.path = [decoder decodeObjectForKey:@"path"];
    
    return self;
}
-(NSMutableDictionary *) getDictionary
{
    NSMutableDictionary *dictionary = [super getDictionary];
    return dictionary;
    
}

@end
