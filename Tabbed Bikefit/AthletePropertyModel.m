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

        NSMutableDictionary *athleteItem = [[NSMutableDictionary alloc] init];
        
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
        ///Update the lastupdated timetamp
        NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
        [athleteItem setObject:[[DynamoDBAttributeValue alloc]
                                    initWithS:[NSString stringWithFormat:@"%f",[now timeIntervalSince1970]]]
                                    forKey:AWS_FIT_ATTRIBUTE_LASTUPDATED];
        
    
        DynamoDBPutItemRequest *putRequest = [[DynamoDBPutItemRequest alloc] initWithTableName:@"fits" andItem:athleteItem];
    
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
    
    [[NSUserDefaults standardUserDefaults] setObject:fitid forKey:USER_DEFAULTS_FITID_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
        NSString *fitterKey = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_FITTER_KEY_KEY];
        DynamoDBAttributeValue *fitterKeyAttribute = [[DynamoDBAttributeValue alloc] initWithS:fitterKey];
        
        DynamoDBCondition *fitterCondition = [[DynamoDBCondition alloc] init];
        [fitterCondition addAttributeValueList:fitterKeyAttribute];
        [fitterCondition setComparisonOperator:@"EQ"];
        
        DynamoDBCondition *fitidCondition = [[DynamoDBCondition alloc] init];
        [fitidCondition setComparisonOperator:@"NOT_NULL"];
    
        //Create a DynamoDB Request that will get the fields we want to return
        DynamoDBScanRequest *request = [[DynamoDBScanRequest alloc] initWithTableName:@"fits"];
        [[request scanFilter] setObject:fitterCondition forKey:AWS_FIT_ATTRIBUTE_FITTERKEY];
        [[request scanFilter] setObject:fitidCondition forKey:AWS_FIT_ATTRIBUTE_FITID];
        
        request.attributesToGet = [[NSMutableArray alloc] initWithObjects:
                                   AWS_FIT_ATTRIBUTE_FITID,
                                   AWS_FIT_ATTRIBUTE_FIRSTNAME,
                                   AWS_FIT_ATTRIBUTE_LASTNAME,
                                   AWS_FIT_ATTRIBUTE_EMAIL,
                                   AWS_FIT_ATTRIBUTE_LASTUPDATED,
                                   AWS_FIT_ATTRIBUTE_FITTERKEY,
                                   nil];
    
        DynamoDBScanResponse *response;
    
        @try{
            NSLog(@"Querying AWS for athletes for the Fitter Key%@", fitterKey);
            response = [ddb scan:request];
        }
        @catch (AmazonServiceException *e)
        {
            NSLog(@"Error Retrieving Fits for Fitter Key %@ - %@", fitterKey, [e description]);
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
            
            //Dont' include local files from other fitter keys
            if(![[athleteAttributes objectForKey:AWS_FIT_ATTRIBUTE_FITTERKEY]
                isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTER_KEY_KEY]])
            {
                continue;
            }
            
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
+ (void) loadAthleteFromAWS:(NSString*) FitID
{
    [[NSUserDefaults standardUserDefaults] setObject:FitID forKey:USER_DEFAULTS_FITID_KEY];
    
    //First get the local filesystem version, if it exists
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[path stringByAppendingString:[NSString stringWithFormat:@"/%@.fit",FitID]]];
    athleteProperties = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if(!athleteProperties)
    {
        athleteProperties = [[NSMutableDictionary alloc] init];
    }
    
    //then get the cloud version of the fit and if it's more up to date, load that one.
    if([AmazonClientManager verifyUserKey])
    {
        NSString *fitterKey = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_FITTER_KEY_KEY];
        
        DynamoDBAttributeValue *fitterKeyAttribute = [[DynamoDBAttributeValue alloc] initWithS:fitterKey];
        DynamoDBAttributeValue *fitIDAttribute = [[DynamoDBAttributeValue alloc] initWithS:FitID];
        //create a ddb request for the item for this fit id
        DynamoDBGetItemRequest *request = [[DynamoDBGetItemRequest alloc]initWithTableName:@"fits"
                                            andKey:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    fitterKeyAttribute, AWS_FIT_ATTRIBUTE_FITTERKEY,
                                                    fitIDAttribute, AWS_FIT_ATTRIBUTE_FITID,
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
                        [athleteProperties setObject:[[[response item] objectForKey:propertyName] s] forKey:propertyName];
                    }
                }
                //if all was successful, update the last email property in case of crasehs
                [[NSUserDefaults standardUserDefaults] setObject:FitID forKey:USER_DEFAULTS_FITID_KEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
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
    [athleteProperties setObject:[[NSUUID UUID] UUIDString] forKey:AWS_FIT_ATTRIBUTE_FITID];
    NSString *fitterKey = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTER_KEY_KEY];
    [athleteProperties setObject:fitterKey forKey:AWS_FIT_ATTRIBUTE_FITTERKEY];
    
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
