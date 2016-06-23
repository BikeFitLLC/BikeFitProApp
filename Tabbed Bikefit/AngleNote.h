//
//  LegAngleNote.h
//  bikefit
//
//  Created by Alfonso Lopez on 12/13/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageNote.h"

@interface AngleNote : ImageNote
{
    float angle;
    NSString *labelText;
    NSMutableArray *vertices;
}

@property float kneeAngle;
@property float shoulderAngle;
@property float hipAngle;

@property NSMutableArray *kneeVertices;
@property NSMutableArray *shoulderVertices;
@property NSMutableArray *hipVertices;

- (UITableViewCell *) populateTableCell:(UITableViewCell *)cell;
-(int) angleInDegrees;

@end
