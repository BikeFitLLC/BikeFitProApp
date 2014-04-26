//
//  BikeFitTabBarController.h
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 9/26/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AthletePropertyModel.h"

@interface BikeFitTabBarController : UITabBarController 

@property (nonatomic, retain) AthletePropertyModel *athleteProperties;
@end
