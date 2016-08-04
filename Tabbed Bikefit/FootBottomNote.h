//
//  FootBottomNote.h
//  bikefit
//
//  Created by Alfonso Lopez on 12/16/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FitNote.h"

typedef enum : NSUInteger {
    FootPressureIdeal,
    FootPressureSlight,
    FootPressureModest,
    FootPressureExtreme
} FootPressure;

@interface FootBottomNote : FitNote

@property (nonatomic, assign) FootPressure footPressure;

@end
