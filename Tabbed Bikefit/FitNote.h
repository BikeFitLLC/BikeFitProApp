//
//  FitNote.h
//  bikefit
//
//  Created by Alfonso Lopez on 12/10/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FitNote : NSObject <NSCoding>
{
    NSString *text;
    bool leftFoot;
}

@property NSString *text;
@property bool leftFoot;

- (UITableViewCell *) populateTableCell:(UITableViewCell *)cell;
-(NSMutableDictionary *) getDictionary;

@end
