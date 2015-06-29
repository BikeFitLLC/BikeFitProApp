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
@property(nonatomic, retain) NSMutableDictionary *fits;
@property(nonatomic, retain) NSDictionary *lastEvaluatedKey;

+ (int)propertyCount;
+ (NSArray *) propertyNames;
+ (NSMutableDictionary *) fits;

+ (bool)setProperty:(NSString*)propertyName value:(id)value;
+ (id)getProperty:(NSString*)propertyName;
+ (void) removeProperty:(NSString *)propertyName;


+ (void)newAthlete;

+ (void)saveAthleteToAWS;
+ (BFTask *)loadAthleteFromAWS:(NSString*)fitID;
+ (BFTask *) getAthletesFromAws;
+ (void) setOfflineMode:(bool)offlineMode;
+ (BFTask *) removeAthleteFromAWS: (NSString*) fitID;

@end
