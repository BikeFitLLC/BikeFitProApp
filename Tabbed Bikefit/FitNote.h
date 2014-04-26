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
}

@property NSString *text;

- (UITableViewCell *) populateTableCell:(UITableViewCell *)cell;

@end
