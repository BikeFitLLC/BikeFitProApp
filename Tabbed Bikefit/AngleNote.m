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
@synthesize kneeVertices;
@synthesize shoulderVertices;
@synthesize hipVertices;


- (UITableViewCell *) populateTableCell:(UITableViewCell *)cell
{
    CGRect rect = CGRectMake(0.0, 0.0, 50.0, 50.0);
    UIGraphicsBeginImageContext(rect.size); //now it's here.
    
    UIBezierPath *border = [UIBezierPath bezierPathWithRect:rect];
    //Draw a border
    [border setLineWidth:3.0];
    [border setLineJoinStyle:kCGLineJoinBevel];
    [border stroke];
    
    CGFloat scaleX = .05;
    CGFloat scaleY = .05;
    
    CGAffineTransform transform = CGAffineTransformMakeScale(scaleX, scaleY);
    
    path = [[UIBezierPath alloc] init];
    [path moveToPoint:[[kneeVertices objectAtIndex:0] CGPointValue]];
    [path addLineToPoint:[[kneeVertices objectAtIndex:1] CGPointValue]];
    [path addLineToPoint:[[kneeVertices objectAtIndex:2] CGPointValue]];
    [path moveToPoint:[[shoulderVertices objectAtIndex:0] CGPointValue]];
    [path addLineToPoint:[[shoulderVertices objectAtIndex:1] CGPointValue]];
    [path addLineToPoint:[[shoulderVertices objectAtIndex:2] CGPointValue]];
    [path moveToPoint:[[hipVertices objectAtIndex:0] CGPointValue]];
    [path addLineToPoint:[[hipVertices objectAtIndex:1] CGPointValue]];
    [path addLineToPoint:[[hipVertices objectAtIndex:2] CGPointValue]];
    
    //Draw Scaled down version of the knee path
    CGPathRef intermediatePath = CGPathCreateCopyByTransformingPath(path.CGPath, &transform);
    UIBezierPath *transformedPath = [[UIBezierPath alloc] init];
    transformedPath.CGPath = intermediatePath;
    
    [transformedPath setLineWidth:3.0];
    [transformedPath setLineJoinStyle:kCGLineJoinBevel];
    [transformedPath stroke];

    UIImage *angleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsPopContext();
    UIGraphicsEndImageContext();
    cell.imageView.image = angleImage;
    
    NSMutableArray *cellLabelStringArray = [[NSMutableArray alloc] init];
    if(kneeVertices)
    {
        int intAngle = (int)(self.kneeAngle * 57.2957795);
        NSString *kneeString = [NSString stringWithFormat:@"Knee Flexion %d°\nKnee Angle %d° ",
                                             180-intAngle,
                                            intAngle];
        [cellLabelStringArray addObject:kneeString];
    }
    if(shoulderVertices)
    {
        int intAngle = (int)(self.shoulderAngle * 57.2957795);
        NSString *shoulderString = [NSString stringWithFormat:@"Shoulder Flexion %d° ", intAngle];
        [cellLabelStringArray addObject:shoulderString];
    }
    if(shoulderVertices)
    {
        int intAngle = (int)(self.hipAngle * 57.2957795);
        NSString *hipString = [NSString stringWithFormat:@"Hip Flexion %d° ", intAngle];
        [cellLabelStringArray addObject:hipString];
    }
    
    
    cell.textLabel.numberOfLines = 4;
    cell.textLabel.text = [cellLabelStringArray componentsJoinedByString:@"\n"];
    return cell;
}

-(int) angleInDegrees
{
    return (int)(angle/0.0174532925);
}

#pragma mark - NSCoding support
-(void)encodeWithCoder:(NSCoder*)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeFloat:self.kneeAngle forKey:@"kneeAngle"];
    [encoder encodeFloat:self.shoulderAngle forKey:@"shoulderAngle"];
    [encoder encodeFloat:self.hipAngle forKey:@"hipAngle"];
    
    [encoder encodeObject:self.kneeVertices forKey:@"kneeVertices"];
    [encoder encodeObject:self.shoulderVertices forKey:@"shoulderVertices"];
    [encoder encodeObject:self.hipVertices forKey:@"hipVertices"];
}

-(id)initWithCoder:(NSCoder*)decoder {
    self.kneeAngle = [decoder decodeFloatForKey:@"angle"]; //legacy, do not erase
    if( !self.kneeAngle)
    {
        self.kneeAngle = [decoder decodeFloatForKey:@"kneeAngle"];
    }
    self.shoulderAngle = [decoder decodeFloatForKey:@"shoulderAngle"];
    self.hipAngle = [decoder decodeFloatForKey:@"hipAngle"];
    
    self.kneeVertices = [decoder decodeObjectForKey:@"vertices"];
    if(!self.kneeVertices)
    {
        self.kneeVertices = [decoder decodeObjectForKey:@"kneeVertices"];
    }
    self.shoulderVertices = [decoder decodeObjectForKey:@"shoulderVertices"];
    self.hipVertices = [decoder decodeObjectForKey:@"hipVertices"];
    
    //self.path = [decoder decodeObjectForKey:@"path"];
    
    return [super initWithCoder:decoder];;
}

-(NSMutableDictionary *) getDictionary
{
    NSMutableDictionary *dictionary = [super getDictionary];
    [dictionary setObject:[NSNumber numberWithFloat:self.kneeAngle ] forKey:@"angle"];
    //[dictionary setObject:self.vertices forKey:@"vertices"];
    
    return dictionary;
    
}

@end
