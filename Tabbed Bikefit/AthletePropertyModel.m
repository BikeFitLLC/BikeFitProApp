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
#import "FitNote.h"
#import "BikefitConstants.h"
#import <Foundation/Foundation.h>

#import "AngleNote.h"
#import "ShoulderAngleNote.h"
#import "AWSSyncErrorManager.h"

//////////////////////////////////////////////////
//Delegate Protocol for loadAthlete
//////////////////////////////////////////////////
@protocol LoadAthleteDelegate
- (void) loadAthleteCompleted;
@end

@implementation AthletePropertyModel
@synthesize athleteProperties;
@synthesize fits;
@synthesize lastEvaluatedKey;


static NSMutableDictionary *athleteProperties;
static NSMutableDictionary *fits;
static NSDictionary *lastEvaluatedKey;


+ (bool)setProperty:(NSString*)propertyName value:(id)value{
    if(!athleteProperties)
    {
        [AthletePropertyModel newAthlete];
    }
    [athleteProperties setObject:value forKey:propertyName];
    
    //Save the property to the defaults in case of a crash
    [AthletePropertyModel saveAthleteToFileSystem];
    if (![propertyName isEqualToString:AWS_FIT_ATTRIBUTE_FITID] &&
        ![propertyName isEqualToString:AWS_FIT_ATTRIBUTE_URL] )
    {
        [AthletePropertyModel saveAthleteToAWS];
    }

    return true;
}

+ (void)saveAthleteToAWS
{
    [AthletePropertyModel saveAthleteToAWS:nil];
}

+ (void)saveAthleteToAWS:(AWSSaveCallback)callback
{
    if([AmazonClientManager verifyLoggedInActive])
    {
        [AthletePropertyModel addJSONNotes];
        [AthletePropertyModel addFitURL];

        NSMutableDictionary *athleteItem = [[NSMutableDictionary alloc] init];
        NSString *fitter = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_FITTERID_KEY];
        AWSDynamoDBAttributeValue *fitterAttribute = [[AWSDynamoDBAttributeValue alloc] init];
        fitterAttribute.S = fitter;
        [athleteItem setObject:fitterAttribute forKey:AWS_FIT_ATTRIBUTE_FITTERID];
        
        for(NSString *propertyName in athleteProperties)
        {
            //If it the note property, archive it first
            if([propertyName isEqualToString:(@"LeftNotes")] || [propertyName isEqualToString:@"RightNotes"])
            {
                
                NSData* notesData = [NSKeyedArchiver archivedDataWithRootObject:[athleteProperties objectForKey:propertyName]];
                AWSDynamoDBAttributeValue *notesDataAttribute = [[AWSDynamoDBAttributeValue alloc] init];
                notesDataAttribute.B = notesData;
                [athleteItem setObject:notesDataAttribute forKey:propertyName];
                 
            }
            else
            {
                NSString * propertyValue = [athleteProperties objectForKey:propertyName];
                if( [propertyValue length] > 0 )
                {
                    AWSDynamoDBAttributeValue *propertyAttribute = [[AWSDynamoDBAttributeValue alloc] init];
                    propertyAttribute.S = propertyValue;

                    [athleteItem setObject:propertyAttribute forKey:propertyName];
                }
            }
        }
        ///Update the lastupdated timetamp
        NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
        AWSDynamoDBAttributeValue *lastupdatedattribute = [[AWSDynamoDBAttributeValue alloc] init];
        lastupdatedattribute.S =[NSString stringWithFormat:@"%f",[now timeIntervalSince1970]];
        [athleteItem setObject:lastupdatedattribute forKey:AWS_FIT_ATTRIBUTE_LASTUPDATED];
        
        AWSDynamoDBPutItemInput *putInput = [[AWSDynamoDBPutItemInput alloc] init];
        putInput.tableName = @"Fits";
        putInput.item = athleteItem;
        
        //AWSLogger.defaultLogger.logLevel = AWSLogLevelVerbose;
        
        [[[AmazonClientManager ddb] putItem:putInput]
         
         continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
             
            if(task.error)
            {
                 NSLog(@"Error Saving Athlete File to Cloud: %@", task.error);
                if (callback) {
                    callback(false,false);
                }
                [AWSSyncErrorManager setAthlete:[self athleteIdentifier]
                                   hadSyncError:true];
                return nil;
            }
            NSLog(@"Saved Athlete to Cloud");
             if (callback) {
                 callback(true,false);
             }
             [AWSSyncErrorManager setAthlete:[self athleteIdentifier]
                                hadSyncError:false];
            return nil;
        }];
    } else {
        if (callback) {
            callback(false,true);
        }
        [AWSSyncErrorManager setAthlete:[self athleteIdentifier]
                           hadSyncError:true];
    }
}


+(void) saveAthleteToFileSystem
{
    NSString *fitid = [athleteProperties objectForKey:AWS_FIT_ATTRIBUTE_FITID];
    
    [athleteProperties setObject:fitid forKey:AWS_FIT_ATTRIBUTE_FITID];
    
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    [athleteProperties setObject:[NSString stringWithFormat:@"%f",[now timeIntervalSince1970]] forKey:AWS_FIT_ATTRIBUTE_LASTUPDATED];
    
    NSError *error = [[NSError alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:athleteProperties];
    
    bool success = [data writeToFile:[path stringByAppendingString:[NSString stringWithFormat:@"/%@.fit",fitid]] options:NSDataWritingAtomic error:&error];
    if(!success)
    {
        NSLog(@"Error Saving to File System: %@", [error description]);
    }
}

+ (AWSTask *) removeAthleteFromAWS: (NSString*) fitID
{
    return [[[AthletePropertyModel loadAthleteFromAWS:fitID] continueWithBlock:^id(AWSTask *task)
    {
        [AthletePropertyModel setProperty:AWS_FIT_ATTRIBUTE_HIDDEN value:@"YES"];
        return task;
    }] continueWithBlock:^id(AWSTask *task)
    {
        [AthletePropertyModel saveAthleteToAWS];
        return task;
    }];
    
    
}

////////////////////////////////////////////////////
//Gets a list of Athletes form AWS
////////////////////////////////////////////////////
+ (AWSTask *) getAthletesFromAws
{
    return [AthletePropertyModel loadFitPageWithExclusiveStartKey:lastEvaluatedKey];
}

+ (AWSTask *) loadFitPageWithExclusiveStartKey:(NSDictionary *)exclusiveStartKey
{
    AWSDynamoDB *ddb = [AmazonClientManager ddb];
    
    //Creat a DynamoDB condition that only matches this fitter's fits
    NSString *fitterID = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_FITTERID_KEY];
    NSString *fitsTableName = @"Fits";

    AWSDynamoDBCondition *condition = [AWSDynamoDBCondition new];
    condition.comparisonOperator = AWSDynamoDBComparisonOperatorEQ;
    AWSDynamoDBAttributeValue *fitterIDAttributeValue = [AWSDynamoDBAttributeValue alloc];
    
    fitterIDAttributeValue.S = fitterID;
    condition.attributeValueList = [[NSArray alloc] initWithObjects:fitterIDAttributeValue, nil];
    
    AWSDynamoDBQueryInput *queryInput = [[AWSDynamoDBQueryInput alloc] init];
    queryInput.tableName = fitsTableName;
    
    queryInput.keyConditions = [NSMutableDictionary dictionaryWithObject:condition forKey:@"FitterID"];
    queryInput.exclusiveStartKey = exclusiveStartKey;
    queryInput.attributesToGet = [[NSMutableArray alloc] initWithObjects:
                                  AWS_FIT_ATTRIBUTE_FITID,
                                  AWS_FIT_ATTRIBUTE_FIRSTNAME,
                                  AWS_FIT_ATTRIBUTE_LASTNAME,
                                  AWS_FIT_ATTRIBUTE_EMAIL,
                                  AWS_FIT_ATTRIBUTE_LASTUPDATED,
                                  AWS_FIT_ATTRIBUTE_HIDDEN,
                                  nil];
    
    
    NSLog(@"Querying AWS for athletes for the FitterID %@", fitterID);
    
    //
    //Block that queries AWS for fits for use in ddb query
    //
    return [[ddb query:queryInput] continueWithBlock:^id(AWSTask *task)
    {
        if(task.error)
        {
            NSLog(@"Error Retrieving Fits %@",[task description]);
            return nil;
        }
        
        if(!fits)
        {
            fits = [[NSMutableDictionary alloc] init];
        }
        
        //Now that we have retrieved the fit items from AWS, put them into the dictionary
        for(NSMutableDictionary *athleteItem in [task.result items])
        {
            if(![athleteItem objectForKey:AWS_FIT_ATTRIBUTE_HIDDEN])
            {
                NSMutableDictionary *athleteAttributes = [[NSMutableDictionary alloc] init];
                for( NSString *key in athleteItem )
                {
                    [athleteAttributes setObject:[[athleteItem valueForKey:key] S] forKey:key];
                }
                [fits setObject:athleteAttributes forKey:[[athleteItem valueForKey:AWS_FIT_ATTRIBUTE_FITID] S]];
            }
        }
        
        lastEvaluatedKey = [task.result lastEvaluatedKey];
        if(lastEvaluatedKey)
        {
            return [AthletePropertyModel getAthletesFromAws];
        }
        return task;
    }];
};



//////////////////////////////////////////////////
//Loads the model with the athlete info at the given
//aws item (DDB)
////////////////////////////////////////////////////
+ (AWSTask *) loadAthleteFromAWS:(NSString*) fitID
{
    [athleteProperties setObject:fitID forKey:AWS_FIT_ATTRIBUTE_FITID];
    
    //First get the local filesystem version, if it exists
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[path stringByAppendingString:[NSString stringWithFormat:@"/%@.fit",fitID]]];
    athleteProperties = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if(!athleteProperties)
    {
        athleteProperties = [[NSMutableDictionary alloc] init];
    }
    
    //then get the cloud version of the fit and if it's more up to date, load that one.
    if([AmazonClientManager verifyLoggedInActive])
    {
        NSString *fitterID = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_FITTERID_KEY];
        NSString *tableName = @"Fits";//[NSString stringWithFormat:AWS_FIT_TABLE_NAME_FORMAT,fitterID];
        
        AWSDynamoDBAttributeValue *fitIDAttribute = [AWSDynamoDBAttributeValue alloc];
        fitIDAttribute.S = fitID;
        AWSDynamoDBAttributeValue *fitterIDAttribute = [AWSDynamoDBAttributeValue alloc];
        fitterIDAttribute.S = fitterID;

        //create a ddb request for the item for this fit id
        AWSDynamoDBGetItemInput *input = [[AWSDynamoDBGetItemInput alloc] init];
        input.tableName = tableName;
        input.key =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                    fitterIDAttribute, AWS_FIT_ATTRIBUTE_FITTERID,
                    fitIDAttribute,  AWS_FIT_ATTRIBUTE_FITID,
                    nil];
        
        //input.consistentRead = true;
        return [[[AmazonClientManager ddb] getItem:input] continueWithBlock:^id(AWSTask *task) {
            if(task.error)
            {
                 NSLog(@"Error Loading Athlete File from AWS: %@", [task description]);
                return nil;
            }
            AWSDynamoDBGetItemOutput *outPut = task.result;
            NSDictionary *item = (NSDictionary *)outPut.item;
            
            if([[[item objectForKey:AWS_FIT_ATTRIBUTE_LASTUPDATED] S] doubleValue] >=
               [[self getProperty:AWS_FIT_ATTRIBUTE_LASTUPDATED] doubleValue])
            {
                for(NSString *propertyName in item)
                {
                    
                    //If it the note property, unarchive it first
                    if([propertyName isEqualToString:(@"LeftNotes")] || [propertyName isEqualToString:@"RightNotes"])
                    {
                        NSData* notesData = [[item objectForKey:propertyName] B];
                        NSMutableDictionary *notes = [NSKeyedUnarchiver unarchiveObjectWithData:notesData];
                        [athleteProperties setObject:notes forKey:propertyName];
                    }
                    else
                    {
                        @try
                        {
                            [athleteProperties setObject:[[item objectForKey:propertyName] S] forKey:propertyName];
                        }
                        @catch(NSException *r)
                        {
                            NSLog(@"Couldn't set property %@ while unarchiving from aws", propertyName);
                        }
                    }
                    NSLog(@"property found: %@", propertyName);
                }
                //if all was successful, update the last email property in case of crasehs
                [athleteProperties setObject:fitID forKey:AWS_FIT_ATTRIBUTE_FITID];
                
                return task;
            }
            return task;
        }];
    }
    return nil;
}

+ (void) newAthlete
{
    athleteProperties = [[NSMutableDictionary alloc] init];
    if([AmazonClientManager verifyLoggedInActive])
    {
        //if we are actively logged in, create new files
        [athleteProperties setObject:[[[NSUUID UUID] UUIDString] lowercaseString] forKey:AWS_FIT_ATTRIBUTE_FITID];
    }
    else
    {
        //otherwise, just use the same file.
        [[NSUserDefaults standardUserDefaults] setObject:LOCAL_FITTER_ID forKey:USER_DEFAULTS_FITTERID_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [athleteProperties setObject:LOCAL_FILE_ID forKey:AWS_FIT_ATTRIBUTE_FITID];
    }
    [athleteProperties setObject:@"" forKey:@"Concerns"];
    [athleteProperties setObject:@"" forKey:@"Previous Fitter"];
    [athleteProperties setObject:@"" forKey:@"Goals For The Fit"];
    [athleteProperties setObject:@"" forKey:@"Current Goals"];
    [athleteProperties setObject:@"" forKey:@"Injuries"];
    [athleteProperties setObject:@"" forKey:@"How Much Are You Riding Per Week"];
    [athleteProperties setObject:@"" forKey:@"Years Cycling"];
    [athleteProperties setObject:@"" forKey:@"Pedals"];
    [athleteProperties setObject:@"" forKey:@"Crank Length"];
    [athleteProperties setObject:@"" forKey:@"Bike"];
    [athleteProperties setObject:@"" forKey:@"Weight"];
    [athleteProperties setObject:@"" forKey:@"Height"];
    [athleteProperties setObject:@"" forKey:@"Age"];
    [athleteProperties setObject:@"" forKey:@"Email"];
    [athleteProperties setObject:@"" forKey:@"LastName"];
    [athleteProperties setObject:@"" forKey:@"FirstName"];
    //NSString *fitterKey = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTER_KEY_KEY];
    //[athleteProperties setObject:fitterKey forKey:AWS_FIT_ATTRIBUTE_FITTERKEY];
    
}

+ (NSString *)athleteIdentifier
{
    if(athleteProperties)
    {
        return [athleteProperties objectForKey:AWS_FIT_ATTRIBUTE_FITID];
    }
    return nil;
}

+ (id)getProperty:(NSString*)propertyName;

{
    if(athleteProperties)
    {
        return [athleteProperties objectForKey:propertyName];
    }
    return nil;
}

+ (void) removeProperty:(NSString *)propertyName
{
    [athleteProperties removeObjectForKey:propertyName];
    [AthletePropertyModel saveAthleteToAWS];
}

+ (int)propertyCount
{
    return [athleteProperties count];
}

+ (NSArray *) propertyNames
{
    return [athleteProperties allKeys];
}

+ (void) setOfflineMode:(bool)offlineMode
{
    if(offlineMode)
    {
        [[NSUserDefaults standardUserDefaults] setObject:LOCAL_FILE_ID forKey:AWS_FIT_ATTRIBUTE_FITID];
        [[NSUserDefaults standardUserDefaults] setObject:LOCAL_FITTER_ID forKey:USER_DEFAULTS_FITTERID_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)addJSONNotes
{
    NSMutableArray *leftJsonArray = [[NSMutableArray alloc] init];
    NSArray *leftNotesArray = [athleteProperties objectForKey:@"LeftNotes"];
    if(leftNotesArray)
    {
        for( FitNote *note in leftNotesArray)
        {
            [leftJsonArray addObject:[note getDictionary]];
        }
        NSError *error;
        NSData *leftNoteJSONData = [NSJSONSerialization dataWithJSONObject:leftJsonArray options:0 error:&error];
        NSString *leftJSONString = [[NSString alloc] initWithData:leftNoteJSONData encoding:NSUTF8StringEncoding];
        [athleteProperties setObject:leftJSONString forKey:@"LeftNotesJSON"];
    }
    
    NSMutableArray *rightJsonArray = [[NSMutableArray alloc] init];
    NSArray *rightNotesArray = [athleteProperties objectForKey:@"RightNotes"];
    if(rightNotesArray)
    {
        for( FitNote *note in rightNotesArray)
        {
            [rightJsonArray addObject:[note getDictionary]];
        }
        NSError *error;
        NSData *rightNoteJSONData = [NSJSONSerialization dataWithJSONObject:rightJsonArray options:0 error:&error];
        NSString *rightJSONString = [[NSString alloc] initWithData:rightNoteJSONData encoding:NSUTF8StringEncoding];
        [athleteProperties setObject:rightJSONString forKey:@"RightNotesJSON"];
    }
}

+ (void) addFitURL
{
    NSString *fitterId = [[NSUserDefaults standardUserDefaults]objectForKey:USER_DEFAULTS_FITTERID_KEY];
    NSString *fitId = [AthletePropertyModel getProperty:AWS_FIT_ATTRIBUTE_FITID];
    if(fitterId && fitterId)
    {
        NSString *url = [NSString stringWithFormat:@"http://intake.bikefit.com/f/%@/%@",fitterId,fitId];
        [AthletePropertyModel setProperty:AWS_FIT_ATTRIBUTE_URL value:url];
    }
}

+ (NSMutableDictionary*) fits
{
    return fits;
}


@end
