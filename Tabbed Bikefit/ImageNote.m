//
//  ImageNote.m
//  bikefit
//
//  Created by Alfonso Lopez on 4/25/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "ImageNote.h"
#import "GlobalOperationQueueManager.h"
#import "BikeFitConstants.h"

@implementation ImageNote
@synthesize image;
@synthesize path;
@synthesize s3Bucket;
@synthesize s3Key;


//////////////////////////////////////
//Queues an operation for uploading this note's image to S3
//This will happen asynchronously
///////////////////////////////////////
-(void)queueImageUpload
{
    GlobalOperationQueueManager *goqp = [GlobalOperationQueueManager queueManager];
    
    NSInvocationOperation *uploadOperation =
    [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(uploadImageToAws) object:nil];

    [[goqp queue] addOperation:uploadOperation];
    
}
/////////////////////////////////////////////////////////////
//Queues up an asynchronous operation that downloads this note's image from S3
///////////////////////////////////////////////////////
-(void)queueImageDownload
{
    GlobalOperationQueueManager *goqp = [GlobalOperationQueueManager queueManager];
    
    NSInvocationOperation *uploadOperation =
    [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImageFromAws) object:nil];
    
    [[goqp queue] addOperation:uploadOperation];
}

//////////////////////////////////////////////////////
//AmazonServiceDelegate methods (for asynch calls to aws
/////////////////////////////////////////////////////////
- (void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)exception
{
    NSLog(@"%@", [exception description]);
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%@", [error description]);
}

- (void)request:(AmazonServiceRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    return;
}

///////////////////////////////////////////////////////
//Downloads this note's image from S3
///////////////////////////////////////////////////////
-(void) downloadImageFromAws
{
    if([AmazonClientManager verifyUserKey])
    {
        @try
        {
            S3GetObjectRequest *request = [[S3GetObjectRequest alloc] initWithKey:s3Key withBucket:s3Bucket];
            S3GetObjectResponse *response = [[AmazonClientManager s3] getObject:request];
    
            image = [response body];
            return;
        }
        @catch(AmazonServiceException *e)
        {
            NSLog(@"Unable To Download Image from AWS. Attempting Filesystem for Key:%@ in Bucket:%@ %@",s3Key, s3Bucket, [e description]);
        }
    }
    ////////////this is a weird codeflow that is probably bad design.
    //the following code will only run if aws is unavailable or if
    //the attempt to get the image from aws failed.   I think it's wonky since the
    //return statement above is being used almost like a goto....
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filepath = [paths objectAtIndex:0];
    NSString *filename = [NSString stringWithFormat:FILESYSTEM_IMAGE_FILENAME_FORMAT, s3Bucket,s3Key];
    image = [NSData dataWithContentsOfFile:[filepath stringByAppendingString:filename]];

    if(!image)
    {
        NSLog(@"Couldn't get image from filesystem.");
    }

}

///////////////////////////////////////////////////////
//Custom setter for the image property.  It queues an s3
//upload in addition to setting the image
///////////////////////////////////////////////////////
-(void)setImage:(NSData*)imageData
{
    image = imageData;
    
    //Upload image data.  Remember to set the content type.
    s3Key = [NSString stringWithFormat:@"%@/%@",
                        [AthletePropertyModel getProperty:AWS_FIT_ATTRIBUTE_FITID],
                        [[NSUUID UUID] UUIDString]];
    
    s3Bucket = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTERID_KEY] lowercaseString];

    //kick off upload to aws s3 or save to filesystem
    if([AmazonClientManager verifyUserKey])
    {
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:s3Key inBucket:s3Bucket];
        
        por.contentType = @"image/jpeg"; // use "image/png" here if you are uploading a png
        por.cannedACL   = [S3CannedACL publicRead];
        por.data        = image;
        por.delegate    = self;
    
        [[AmazonClientManager s3TransferManager] upload:por];
    }
    else
    {
        NSError *error = [[NSError alloc] init];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filepath = [paths objectAtIndex:0];
        NSString *fitPath = [filepath stringByAppendingString:[NSString stringWithFormat:@"/%@",s3Bucket]];
        
        fitPath = [fitPath stringByAppendingString:[NSString stringWithFormat:@"/%@", [[s3Key componentsSeparatedByString:@"/"] objectAtIndex:0]]];

        if(![[NSFileManager defaultManager] fileExistsAtPath:fitPath])
        {
            bool success = [[NSFileManager defaultManager] createDirectoryAtPath:fitPath withIntermediateDirectories:YES attributes:nil error:&error];
            if(success == NO)
            {
                NSLog(@"Error Creating Fit Directory: %@", [error description]);
            }
        }
        NSString *filename = [filepath stringByAppendingString:
                              [NSString stringWithFormat:FILESYSTEM_IMAGE_FILENAME_FORMAT, s3Bucket,s3Key]
                              ];
        bool success = [image writeToFile:filename options:NSDataWritingAtomic error:&error];
        if(!success)
        {
            NSLog(@"Error Saving to File System: %@", [error description]);
        }
    }

}

-(NSData*)getImage
{
    return image;
}

#pragma NSCoding Methods
-(void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:self.s3Key forKey:@"s3Key"];
    [encoder encodeObject:self.s3Bucket forKey:@"s3Bucket"];
    [encoder encodeObject:self.path forKey:@"path"];
}

-(id)initWithCoder:(NSCoder*)decoder {
    self.s3Key = [decoder decodeObjectForKey:@"s3Key"];
    self.s3Bucket = [decoder decodeObjectForKey:@"s3Bucket"];
    self.path = [decoder decodeObjectForKey:@"path"];
    
    [self queueImageDownload];
    
    return self;
}

-(NSMutableDictionary *) getDictionary
{
    NSMutableDictionary *dictionary = [super getDictionary];
    [dictionary setObject:self.s3Key forKey:@"s3Key"];
    [dictionary setObject:self.s3Bucket forKey:@"s3Bucket"];
    //[dictionary setObject:self.path forKey:@"path"];
    
    return dictionary;
    
}

@end
