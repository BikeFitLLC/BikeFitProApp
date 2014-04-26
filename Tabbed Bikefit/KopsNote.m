//
//  KopsNote.m
//  bikefit
//
//  Created by Alfonso Lopez on 3/4/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "KopsNote.h"

@implementation KopsNote

- (UITableViewCell *) populateTableCell:(UITableViewCell *)cell
{
    
    CGRect rect = CGRectMake(0.0, 0.0, 50, 59.3);
    UIGraphicsBeginImageContext(rect.size); //now it's here.
    
    UIBezierPath *border = [UIBezierPath bezierPathWithRect:rect];
    //Draw a border
    [border setLineWidth:3.0];
    [border setLineJoinStyle:kCGLineJoinBevel];
    [border stroke];
    
    CGFloat scaleX = .05;
    CGFloat scaleY = .05;
    
    CGAffineTransform transform = CGAffineTransformMakeScale(scaleX, scaleY);
    
    if(!path)
    {
        path = [[UIBezierPath alloc] init];
    }
    
    //Draw Scaled down version of the knee path
    CGPathRef intermediatePath = CGPathCreateCopyByTransformingPath(path.CGPath, &transform);
    UIBezierPath *transformedPath = [[UIBezierPath alloc] init];
    transformedPath.CGPath = intermediatePath;
    
    [transformedPath setLineWidth:3.0];
    [transformedPath setLineJoinStyle:kCGLineJoinBevel];
    [transformedPath stroke];
    
    UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsPopContext();
    UIGraphicsEndImageContext();
    cell.imageView.image = cellImage;
    
    cell.textLabel.text = [[self class] labelText];
    return cell;
}
+ (NSString*)labelText {
    return @"Knee Over Pedal Spindle";
}
@end
