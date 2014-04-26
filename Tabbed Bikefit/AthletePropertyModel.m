//
//  AthletePropertyModel.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 9/26/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "AthletePropertyModel.h"
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "AmazonClientManager.h"
#import "AmazonKeyChainWrapper.h"
#import "FitNote.h"
#import "BikefitConstants.h"

@implementation AthletePropertyModel
@synthesize athleteProperties;

static NSMutableDictionary *athleteProperties;


+ (bool)setProperty:(NSString*)propertyName value:(id)value{
    if(!athleteProperties)
    {
        athleteProperties  = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    
    [athleteProperties setObject:value forKey:propertyName];
    
    //Save the property to the defaults in case of a crash
    [AthletePropertyModel saveAthleteToFileSystem];

    return true;
}

+ (void)saveAthlete{
    if(![AmazonClientManager verifyUserKey])
    {
        return;
    }

    NSMutableDictionary *athleteItem = [[NSMutableDictionary alloc] init];
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_USERNAME_KEY];
    [athleteItem setObject:[[DynamoDBAttributeValue alloc] initWithS:username] forKey:@"fitter"];
    [athleteItem setObject:[[DynamoDBAttributeValue alloc] initWithS:[self getProperty:@"Email"]] forKey:@"client"];
    for(NSString *propertyName in athleteProperties)
    {
        //If it the note property, archive it first
        if([propertyName isEqualToString:(@"LeftNotes")] || [propertyName isEqualToString:@"RightNotes"])
        {
            NSData* notesData = [NSKeyedArchiver archivedDataWithRootObject:[athleteProperties objectForKey:propertyName]];
            [athleteItem setObject:[[DynamoDBAttributeValue alloc] initWithB:notesData] forKey:propertyName];
        }
        else
        {
            [athleteItem setObject:[[DynamoDBAttributeValue alloc] initWithS:[athleteProperties objectForKey:propertyName]] forKey:propertyName];
        }
    }
    
    DynamoDBPutItemRequest *putRequest = [[DynamoDBPutItemRequest alloc] initWithTableName:@"fits" andItem:athleteItem];
    
    @try{
        [[AmazonClientManager ddb] setEndpoint: [AmazonEndpoints ddbEndpoint:US_WEST_2]];
        [[AmazonClientManager ddb] putItem:putRequest];
    }
    @catch (NSException *e) {
        NSLog(@"Error Saving Athlete File to Cloud: %@", [e description]);
        return;
    }
    
    return;

}


+(void) saveAthleteToFileSystem
{
    NSString *email = [athleteProperties objectForKey:@"Email"];
    if(email)
    {
        [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"lastemail"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSError *error = [[NSError alloc] init];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:athleteProperties];
        bool success = [data writeToFile:[path stringByAppendingString:[NSString stringWithFormat:@"/%@",email]] options:nil error:&error];
        if(!success)
        {
            NSLog(@"Error Saving to File System: %@", [error description]);
        }
    }
    
}
+ (void) loadAthlete:(NSString *) athleteEmail
{
    if(!athleteProperties)
    {
        athleteProperties  = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[path stringByAppendingString:[NSString stringWithFormat:@"/%@",athleteEmail]]];
    athleteProperties = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return;
}

////////////////////////////////////////////////////
//Gets a list of Athletes form AWS
////////////////////////////////////////////////////
+ (NSMutableArray *) getAthletesFromAws
{
    if(![AmazonClientManager verifyUserKey])
    {
        return nil;
    }

    AmazonDynamoDBClient *ddb = [AmazonClientManager ddb];
    
    //Creat a DynamoDB condition that only matches this fitter's fits
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_USERNAME_KEY];
    DynamoDBAttributeValue *fitter = [[DynamoDBAttributeValue alloc] initWithS:username];
    DynamoDBCondition *condition = [[DynamoDBCondition alloc] init];
    [condition addAttributeValueList:fitter];
    [condition setComparisonOperator:@"EQ"];
    
    DynamoDBQueryRequest *request = [[DynamoDBQueryRequest alloc] initWithTableName:@"fits"];
    [request setKeyConditionsValue:condition forKey:@"fitter"];
    request.attributesToGet = [[NSMutableArray alloc] initWithObjects:@"client", nil];
    
    DynamoDBQueryResponse *response;
    
    @try{
        NSLog(@"Querying AWS for athletes for the fitter %@", username);
        [ddb setEndpoint: [AmazonEndpoints ddbEndpoint:US_WEST_2]];
        response = [ddb query:request];
    }
    @catch (AmazonServiceException *e)
    {
        return nil;
    }
    NSMutableArray *athleteNames = [[NSMutableArray alloc]init];
    for(NSMutableDictionary *athleteItem in [response items])
    {
        DynamoDBAttributeValue *attribute = [athleteItem valueForKey:@"client"];
        [athleteNames addObject:[attribute s]];
    }
    
    return athleteNames;
}

//////////////////////////////////////////////////
//Loads the model with the athlete info at the given
//aws item (DDB)
////////////////////////////////////////////////////
+ (void) loadAthleteFromAWS:(NSString*) athleteItem
{
    if(![AmazonClientManager verifyUserKey])
    {
        return;
    }

    [self newAthlete];
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_USERNAME_KEY];
    DynamoDBAttributeValue *fitter = [[DynamoDBAttributeValue alloc] initWithS:username];
    DynamoDBAttributeValue *client = [[DynamoDBAttributeValue alloc] initWithS:athleteItem];
    DynamoDBGetItemRequest *request = [[DynamoDBGetItemRequest alloc]initWithTableName:@"fits"
                                    andKey:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            fitter, @"fitter",
                                            client, @"client",
                                            nil]];
    request.consistentRead = YES;
    
    @try {
        [[AmazonClientManager ddb] setEndpoint: [AmazonEndpoints ddbEndpoint:US_WEST_2]];
        DynamoDBGetItemResponse *response = [[AmazonClientManager ddb] getItem:request];
        for(NSString *propertyName in [response item])
        {
            //If it the note property, archive it first
            if([propertyName isEqualToString:(@"LeftNotes")] || [propertyName isEqualToString:@"RightNotes"])
            {
                NSData* notesData = [[[response item] objectForKey:propertyName] b];
                NSMutableDictionary *notes = [NSKeyedUnarchiver unarchiveObjectWithData:notesData];
                [self setProperty:propertyName value:notes];
            }
            else
            {
                [self setProperty:propertyName value:[[[response item] objectForKey:propertyName] s]];
            }
        }
        //if all was successful, update the last email property in case of crasehs
        [[NSUserDefaults standardUserDefaults] setObject:athleteItem forKey:@"lastemail"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    @catch (AmazonServiceException *exception) {
        NSLog(@"Error Loading Athlete File from AWS: %@", [exception description]);
        return;
    }
    
    return;
//    athleteProperties = [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (void) newAthlete
{
    [athleteProperties removeAllObjects];
}

+ (id)getProperty:(NSString*)propertyName;

{
    if(athleteProperties)
    {
        return [athleteProperties objectForKey:propertyName];
    }
    return nil;
}


@end
