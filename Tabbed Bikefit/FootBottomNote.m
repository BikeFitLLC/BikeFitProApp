//
//  FootBottomNote.m
//  bikefit
//
//  Created by Alfonso Lopez on 12/16/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "FootBottomNote.h"

@implementation FootBottomNote
@synthesize centerOfPressure;
@synthesize footBoxPath;

- (UITableViewCell *) populateTableCell:(UITableViewCell *)cell
{
    CGRect rect = CGRectMake(0.0, 0.0, 50.0, 50.0);
    //CGContextRef context = UIGraphicsGetCurrentContext();
    //UIGraphicsPushContext(context);
    UIGraphicsBeginImageContext(rect.size);
    
    UIBezierPath *border = [UIBezierPath bezierPathWithRect:rect];
    //Draw a border
    [border setLineWidth:3.0];
    [border setLineJoinStyle:kCGLineJoinBevel];
    [border stroke];
    
    //create a square fo rhte center of foot pressue
    UIBezierPath *centerOfPressurePath =
        [UIBezierPath bezierPathWithRect:CGRectMake(centerOfPressure.x,centerOfPressure.y, 50.0, 50.0)];
    
    //Add the foot box path
    [centerOfPressurePath appendPath:footBoxPath];

    //Set the scale we will transorm too
    CGFloat scaleX = .05;
    CGFloat scaleY = .05;
    CGAffineTransform transform = CGAffineTransformMakeScale(scaleX, scaleY);
    
    CGAffineTransform translation = CGAffineTransformMakeTranslation(100, 0);
    
    //Move the path to the right
    CGPathRef intermediatePath = CGPathCreateCopyByTransformingPath(centerOfPressurePath.CGPath, &translation);
    centerOfPressurePath.CGPath = intermediatePath;
    //append the foot box path

    //transform the centerofpressure and footbox path
    intermediatePath = CGPathCreateCopyByTransformingPath(centerOfPressurePath.CGPath, &transform);
    centerOfPressurePath = [[UIBezierPath alloc] init];
    centerOfPressurePath.CGPath = intermediatePath;
    
    //draw the center of pressure  and foot box path
    [centerOfPressurePath setLineWidth:3.0];
    [centerOfPressurePath setLineJoinStyle:kCGLineJoinBevel];
    [centerOfPressurePath stroke];
    
    //CGContextAddPath(context, centerOfPressurePath.CGPath);

    
    UIImage *angleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsPopContext();
    UIGraphicsEndImageContext();
    cell.imageView.image = angleImage;
    cell.textLabel.text = @"Center of Pressure"; //[NSString stringWithFormat:@"%f - %f",self.centerOfPressure.x, self.centerOfPressure.y];
    
    return cell;
    
}

#pragma mark - NSCoding support
-(void)encodeWithCoder:(NSCoder*)encoder {
    
    [encoder encodeCGPoint:self.centerOfPressure forKey:@"centerOfPressure"];
    [encoder encodeObject:self.footBoxPath forKey:@"footBoxPath"];
}

-(id)initWithCoder:(NSCoder*)decoder {
    self.centerOfPressure = [decoder decodeCGPointForKey:@"centerOfPressure"];
    self.footBoxPath = [decoder decodeObjectForKey:@"footBoxPath"];
    
    return self;
}
-(NSMutableDictionary *) getDictionary
{
    NSMutableDictionary *dictionary = [super getDictionary];
    return dictionary;
    
}

@end
