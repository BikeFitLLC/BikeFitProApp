//
//  FootBottomNote.h
//  bikefit
//
//  Created by Alfonso Lopez on 12/16/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FitNote.h"

@interface FootBottomNote : FitNote
{
    CGPoint centerOfPressure;
    UIBezierPath *footBoxPath;
}

@property CGPoint centerOfPressure;
@property UIBezierPath *footBoxPath;

@end
