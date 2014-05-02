//
//  AthletePropertyModel.h
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 9/26/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AthletePropertyModel : NSObject{
}

@property(nonatomic, retain) NSMutableDictionary *athleteProperties;

+ (bool)setProperty:(NSString*)propertyName value:(id)value;
+ (id)getProperty:(NSString*)propertyName;


+ (void)newAthlete;

+ (void)saveAthleteToAWS;
+ (void)loadAthleteFromAWS:(NSString*) athleteItem;
+ (NSMutableDictionary *) getAthletesFromAws;

@end
