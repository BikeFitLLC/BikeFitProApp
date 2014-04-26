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
//+ (NSString *) awsUsername;
//+ (NSString *) awsPassword;


@property(nonatomic, retain) NSMutableDictionary *athleteProperties;
+ (bool)setProperty:(NSString*)propertyName value:(id)value;
+ (id)getProperty:(NSString*)propertyName;
+ (void)saveAthlete;
+ (void) loadAthlete:(NSString*) athletePath;
+ (void) newAthlete;

+ (void) loadAthleteFromAWS:(NSString*) athleteItem;
+ (NSMutableArray *) getAthletesFromAws;

+ (void) initAWS;
+(void) logOutAWS;
+ (void) setCredentialsWithUsername:(NSString*)username andPassword:(NSString*)password;

@end
