//
//  ImageNote.m
//  bikefit
//
//  Created by Alfonso Lopez on 4/25/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "ImageNote.h"
#import "AmazonClientManager.h"
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


///////////////////////////////////////////////////////
//Uploads this notes image to s3.  called asnychronously
///////////////////////////////////////////////////////
-(void) uploadImageToAws
{
    if([AmazonClientManager verifyUserKey])
    {
        @try {
            //Gets alist of existing buckets and if this user doesn't have one yet
            //it creates one.
            NSArray *buckets = [[AmazonClientManager s3] listBuckets];
            if([buckets indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                S3Bucket *bucket = (S3Bucket*)obj;
                return [[bucket name] isEqualToString:s3Bucket];
            }] == NSNotFound)
            {
                //After searching through the bucket we didn't find this user's bucket.  So create it.
                S3CreateBucketRequest *createRequest =
                    [[S3CreateBucketRequest alloc] initWithName:s3Bucket andRegion:[S3Region USWest2]];
                [[AmazonClientManager s3] createBucket:createRequest];
            }
            
            S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:s3Key inBucket:s3Bucket];
            
            por.contentType = @"image/jpeg"; // use "image/png" here if you are uploading a png
            por.cannedACL   = [S3CannedACL publicRead];
            por.data        = image;
            //por.delegate    = self; // Don't need this line if you don't care about hearing a response.
            
            // Put the image data into the specified s3 bucket and object.
            [[AmazonClientManager s3] putObject:por];
        }
        @catch (AmazonClientException *exception) {
            NSLog(@"Exception Uploading Image Note Image to AWS: %@", [exception description]);
        }
    }
    else //if aws is not available, save to the file system
    {
        NSError *error = [[NSError alloc] init];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filepath = [paths objectAtIndex:0];
        NSString *filename = [NSString stringWithFormat:FILESYSTEM_IMAGE_FILENAME_FORMAT, s3Bucket,s3Key];
        bool success = [image writeToFile:[filepath stringByAppendingString:filename] options:NSDataWritingAtomic error:&error];
        if(!success)
        {
            NSLog(@"Error Saving to File System: %@", [error description]);
        }
    }
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
            NSLog(@"Unable To Download Image from AWS. Attempting Filesystem: %@", [e description]);
        }
    }
    ////////////this is a weird codeflow that is probably bad design.
    //the following code will only run if aws is unavailable or if
    //the attempt to get the image from aws failed.   I think it's wonky since the
    //return statement above is being used almost like a goto....
    NSError *error = [[NSError alloc] init];
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
    s3Key = [[NSUUID UUID] UUIDString];
    s3Bucket = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITID_KEY] lowercaseString];

    //kick off upload to aws s3 or save to filesystem
    [self queueImageUpload];

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
@end
