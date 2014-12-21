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
#import "JSONKit.h"

#import "AngleNote.h"
#import "ShoulderAngleNote.h"

@implementation AthletePropertyModel
@synthesize athleteProperties;

static NSMutableDictionary *athleteProperties;


+ (bool)setProperty:(NSString*)propertyName value:(id)value{
    if(!athleteProperties)
    {
        [AthletePropertyModel newAthlete];
    }
    [athleteProperties setObject:value forKey:propertyName];
    
    //Save the property to the defaults in case of a crash
    [AthletePropertyModel saveAthleteToFileSystem];

    return true;
}

+ (void)saveAthleteToAWS{
    if([AmazonClientManager verifyUserKey])
    {
        [AthletePropertyModel addJSONNotes];
        [AthletePropertyModel addFitURL];

        NSMutableDictionary *athleteItem = [[NSMutableDictionary alloc] init];
        NSString *fitter = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_FITTERID_KEY];
        [athleteItem setObject:[[DynamoDBAttributeValue alloc] initWithS:fitter]
                     forKey:AWS_FIT_ATTRIBUTE_FITTERID];
        
        for(NSString *propertyName in athleteProperties)
        {
            //If it the note property, archive it first
            if([propertyName isEqualToString:(@"LeftNotes")] || [propertyName isEqualToString:@"RightNotes"])
            {
                NSData* notesData = [NSKeyedArchiver archivedDataWithRootObject:[athleteProperties objectForKey:propertyName]];
                [athleteItem setObject:[[   DynamoDBAttributeValue alloc] initWithB:notesData] forKey:propertyName];
            }
            else
            {
                NSString * propertyValue = [athleteProperties objectForKey:propertyName];
                if( [propertyValue length] > 0 )
                {
                    [athleteItem setObject:[[DynamoDBAttributeValue alloc] initWithS:propertyValue] forKey:propertyName];
                }
            }
        }
        ///Update the lastupdated timetamp
        NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
        [athleteItem setObject:[[DynamoDBAttributeValue alloc]
                                    initWithS:[NSString stringWithFormat:@"%f",[now timeIntervalSince1970]]]
                                    forKey:AWS_FIT_ATTRIBUTE_LASTUPDATED];
        
        DynamoDBPutItemRequest *putRequest = [[DynamoDBPutItemRequest alloc] initWithTableName:@"Fits" andItem:athleteItem];
    
        @try{
            [[AmazonClientManager ddb] putItem:putRequest];
        }
        @catch (NSException *e) {
            NSLog(@"Error Saving Athlete File to Cloud: %@", [e description]);
            return;
        }
    }
    return;
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

////////////////////////////////////////////////////
//Gets a list of Athletes form AWS
////////////////////////////////////////////////////
+ (NSMutableDictionary *) getAthletesFromAws
{
    NSMutableDictionary *athletes = [[NSMutableDictionary alloc]init];
    
    if([AmazonClientManager verifyUserKey])
    {
        AmazonDynamoDBClient *ddb = [AmazonClientManager ddb];
    
        //Creat a DynamoDB condition that only matches this fitter's fits
        NSString *fitterID = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_FITTERID_KEY];
        NSString *fitsTableName = @"Fits";
        
        DynamoDBCondition *condition = [DynamoDBCondition new];
        condition.comparisonOperator = @"EQ";
        DynamoDBAttributeValue *fitterIDAttributeValue = [[DynamoDBAttributeValue alloc] initWithS:fitterID];
        [condition addAttributeValueList:fitterIDAttributeValue];
        
        DynamoDBQueryRequest *request = [[DynamoDBQueryRequest alloc] initWithTableName:fitsTableName];
        request.keyConditions = [NSMutableDictionary dictionaryWithObject:condition forKey:@"FitterID"];
        
        request.attributesToGet = [[NSMutableArray alloc] initWithObjects:
                                   AWS_FIT_ATTRIBUTE_FITID,
                                   AWS_FIT_ATTRIBUTE_FIRSTNAME,
                                   AWS_FIT_ATTRIBUTE_LASTNAME,
                                   AWS_FIT_ATTRIBUTE_EMAIL,
                                   AWS_FIT_ATTRIBUTE_LASTUPDATED,
                                   nil];
    
        DynamoDBQueryResponse *response;
    
        @try{
            NSLog(@"Querying AWS for athletes for the FitterID %@", fitterID);
            response = [ddb query:request];
        }
        @catch (AmazonServiceException *e)
        {
            NSLog(@"Error Retrieving Fits for FitterID %@ - %@", fitterID, [e description]);
        }
        
        //Now that we have retrieved the fit items from AWS, put them into the dictionary
        for(NSMutableDictionary *athleteItem in [response items])
        {
            NSMutableDictionary *athleteAttributes = [[NSMutableDictionary alloc] init];
            for( NSString *key in athleteItem )
            {
                [athleteAttributes setObject:[[athleteItem valueForKey:key] s] forKey:key];
            }
            [athletes setObject:athleteAttributes forKey:[[athleteItem valueForKey:AWS_FIT_ATTRIBUTE_FITID] s]];
        }
    } //end AWS block

    //get local files
    NSError *error = [[NSError alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    
    for( NSString *filename in directoryContents)
    {
        if([filename hasSuffix:@".fit"])
        {
            NSString *fitid = [filename stringByDeletingPathExtension];

            NSData *localFileData = [NSData dataWithContentsOfFile:[NSString pathWithComponents:[NSArray arrayWithObjects:path,filename,nil]]];
            NSMutableDictionary *localFileDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:localFileData];
            
            NSMutableDictionary *athleteAttributes = [[NSMutableDictionary alloc] init];
            for( NSString *key in localFileDictionary )
            {
                [athleteAttributes setObject:[localFileDictionary valueForKey:key] forKey:key];
            }
            [athleteAttributes setObject:[NSNumber numberWithBool:true] forKey:FIT_ATTRIBUTE_FROMFILESYSTEM];
            bool addLocalFile = YES;
            
            //if aws returned this same fit, compare the last updated dates and keep the newest version
            if([athletes objectForKey:fitid])
            {
                double localFileLastUpdate = [[athleteAttributes objectForKey:AWS_FIT_ATTRIBUTE_LASTUPDATED] doubleValue];
                double awsLastUpdate = [[[athletes objectForKey:fitid] objectForKey:AWS_FIT_ATTRIBUTE_LASTUPDATED] doubleValue];
                
                addLocalFile = awsLastUpdate < localFileLastUpdate;
            }
            
            if(addLocalFile)
            {
                [athletes setObject:athleteAttributes forKey:fitid];
            }
            
        }
    }
    return athletes;
}

//////////////////////////////////////////////////
//Loads the model with the athlete info at the given
//aws item (DDB)
////////////////////////////////////////////////////
+ (void) loadAthleteFromAWS:(NSString*) fitID
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
    if([AmazonClientManager verifyUserKey])
    {
        NSString *fitterID = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_FITTERID_KEY];
        NSString *tableName = @"Fits";//[NSString stringWithFormat:AWS_FIT_TABLE_NAME_FORMAT,fitterID];
        
        DynamoDBAttributeValue *fitIDAttribute = [[DynamoDBAttributeValue alloc] initWithS:fitID];
        DynamoDBAttributeValue *fitterIDAttribute = [[DynamoDBAttributeValue alloc] initWithS:fitterID];

        //create a ddb request for the item for this fit id
        DynamoDBGetItemRequest *request = [[DynamoDBGetItemRequest alloc]initWithTableName:tableName
                                            andKey:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    fitterIDAttribute, AWS_FIT_ATTRIBUTE_FITTERID,
                                                    fitIDAttribute,  AWS_FIT_ATTRIBUTE_FITID,
                                                    nil]];
        request.consistentRead = YES;
    
        @try {
            DynamoDBGetItemResponse *response = [[AmazonClientManager ddb] getItem:request];
            
            if([[[[response item] objectForKey:AWS_FIT_ATTRIBUTE_LASTUPDATED] s] doubleValue] >=
                                [[self getProperty:AWS_FIT_ATTRIBUTE_LASTUPDATED] doubleValue])
            {
                for(NSString *propertyName in [response item])
                {
                    //If it the note property, unarchive it first
                    if([propertyName isEqualToString:(@"LeftNotes")] || [propertyName isEqualToString:@"RightNotes"])
                    {
                        NSData* notesData = [[[response item] objectForKey:propertyName] b];
                        NSMutableDictionary *notes = [NSKeyedUnarchiver unarchiveObjectWithData:notesData];
                        [athleteProperties setObject:notes forKey:propertyName];
                    }
                    else
                    {
                        @try
                        {
                            [athleteProperties setObject:[[[response item] objectForKey:propertyName] s] forKey:propertyName];
                        }
                        @catch(NSException *r)
                        {
                            NSLog(@"Couldn't set property %@ while unarchiving from aws", propertyName);
                        }
                    }
                }
                //if all was successful, update the last email property in case of crasehs
                [athleteProperties setObject:fitID forKey:AWS_FIT_ATTRIBUTE_FITID];

                return;
            }
        }
        @catch (AmazonServiceException *exception) {
            NSLog(@"Error Loading Athlete File from AWS: %@", [exception description]);
            return;
        }
    }
    return;
}

+ (void) newAthlete
{
    athleteProperties = [[NSMutableDictionary alloc] init];
    if([AmazonClientManager verifyUserKey])
    {
        //if we are actively logged in, create new files
        [athleteProperties setObject:[[[NSUUID UUID] UUIDString] lowercaseString] forKey:AWS_FIT_ATTRIBUTE_FITID];
    }
    else
    {
        //otherwise, just use the same file.
        [[NSUserDefaults standardUserDefaults] setObject:LOCAL_FITTER_ID forKey:USER_DEFAULTS_FITTERID_KEY];
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

+ (id)getProperty:(NSString*)propertyName;

{
    if(athleteProperties)
    {
        return [athleteProperties objectForKey:propertyName];
    }
    return nil;
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
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
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
        [athleteProperties setObject:[leftJsonArray JSONString] forKey:@"LeftNotesJSON"];
    }
    
    NSMutableArray *rightJsonArray = [[NSMutableArray alloc] init];
    NSArray *rightNotesArray = [athleteProperties objectForKey:@"RightNotes"];
    if(rightNotesArray)
    {
        for( FitNote *note in rightNotesArray)
        {
            [rightJsonArray addObject:[note getDictionary]];
        }
        NSString *json = [rightJsonArray JSONString];
        [athleteProperties setObject:json forKey:@"RightNotesJSON"];
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


@end
