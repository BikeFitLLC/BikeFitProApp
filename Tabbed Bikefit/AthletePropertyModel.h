//
//  AthletePropertyModel.h
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 9/26/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AmazonClientManager.h"

@interface AthletePropertyModel : NSObject
{
}

@property(nonatomic, retain) NSMutableDictionary *athleteProperties;

+ (int)propertyCount;
+ (NSArray *) propertyNames;

+ (bool)setProperty:(NSString*)propertyName value:(id)value;
+ (id)getProperty:(NSString*)propertyName;


+ (void)newAthlete;

+ (void)saveAthleteToAWS;
+ (BFTask *)loadAthleteFromAWS:(NSString*)fitID;
+ (BFTask *) getAthletesFromAws;
+ (void) setOfflineMode:(bool)offlineMode;
+ (BFTask *) removeAthleteFromAWS: (NSString*) fitID;

@end
