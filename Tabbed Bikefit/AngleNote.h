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

@property float angle;
@property NSString* labelText;
@property NSMutableArray *vertices;

- (UITableViewCell *) populateTableCell:(UITableViewCell *)cell;
-(int) angleInDegrees;

@end
