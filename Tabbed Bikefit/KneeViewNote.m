    //
//  KneeViewNote.m
//  bikefit
//
//  Created by Alfonso Lopez on 12/14/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "KneeViewNote.h"
#import "AmazonClientManager.h"
#import "BikefitConstants.h"
#import "GlobalOperationQueueManager.h"

@implementation KneeViewNote
@synthesize path;
@synthesize videoUrl;
@synthesize lazerPath;
@synthesize selectedFrameIndex;
@synthesize startingPoint;
@synthesize s3Key;
@synthesize s3Bucket;

+ (NSString*)labelText {
    return @"Cleat Medial/Lateral";
}

- (UITableViewCell *) populateTableCell:(UITableViewCell *)cell
{
    
    CGRect rect = CGRectMake(0.0, 0.0, 50, 59.3);
    UIGraphicsBeginImageContext(rect.size); //now it's here.
    
    UIBezierPath *border = [UIBezierPath bezierPathWithRect:rect];
    //Draw a border
    [border setLineWidth:3.0];
    [border setLineJoinStyle:kCGLineJoinBevel];
    [border stroke];
    
    CGFloat scaleX = .10;
    CGFloat scaleY = .05;
    
    CGAffineTransform transform = CGAffineTransformMakeScale(scaleX, scaleY);
    
    if(!path)
    {
        path = [[UIBezierPath alloc] init];
    }
    if(lazerPath)
    {
            [path appendPath:lazerPath];
    }
    
    //Draw Scaled down version of the knee path
    CGPathRef intermediatePath = CGPathCreateCopyByTransformingPath(path.CGPath, &transform);
    UIBezierPath *transformedPath = [[UIBezierPath alloc] init];
    transformedPath.CGPath = intermediatePath;
    
    [transformedPath setLineWidth:1.0];
    [transformedPath setLineJoinStyle:kCGLineJoinBevel];
    [transformedPath stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsPopContext();
    UIGraphicsEndImageContext();
    cell.imageView.image = image;

    cell.textLabel.text = [[self class] labelText];
    return cell;
}

//////////////////////////////////////
//Queues an operation for uploading this note's image to S3
//This will happen asynchronously
///////////////////////////////////////
-(void)queueVideoUpload
{
    GlobalOperationQueueManager *goqp = [GlobalOperationQueueManager queueManager];
    
    NSInvocationOperation *uploadOperation =
    [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(uploadVideoToAWS) object:nil];
    
    [[goqp queue] addOperation:uploadOperation];

}

-(void)uploadVideoToAWS
{
    if([AmazonClientManager verifyLoggedInActive])
    {
        // Upload image data.  Remember to set the content type.
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        uploadRequest.bucket = s3Bucket;
        uploadRequest.key = s3Key;
        uploadRequest.contentType = @"video/quicktime"; // use "image/png" here if you are uploading a png
        uploadRequest.body        = localVideoUrl;
        uploadRequest.ACL  = AWSS3ObjectCannedACLPublicRead;

        //por.delegate    = self; // Don't need this line if you don't care about hearing a response.
        
        // Put the image data into the specified s3 bucket and object.
        [[[AmazonClientManager s3TransferManager] upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                                                   withBlock:^id(AWSTask *task)
        {
            if (task.error)
            {
                NSLog(@"Error: %@", task.error);
                return nil;
            }
            videoUrl= [[NSURL alloc] initWithString:
                       [NSString stringWithFormat:S3_IMAGE_URL_FORMAT,
                        s3Bucket,
                        s3Key
                        ]];
            NSLog(@"Uploaded Video to AWS: %@", videoUrl);
            [AthletePropertyModel saveAthleteToAWS];
            return task;
        }];
        
       
    }
}
-(void)setVideoUrl:(NSURL *)url
{
    localVideoUrl = url;
    s3Key = [[NSUUID UUID] UUIDString];
    s3Bucket = S3_BUCKET;
    
    [self uploadVideoToAWS];
}

-(NSURL *)getVideoUrl
{
    NSError *err;
    if ([localVideoUrl checkResourceIsReachableAndReturnError:&err] == NO)
    {
        NSLog(@"KnewViewNote: local file no longer exists, going to aws copy");
        return videoUrl;
    }
    
    return localVideoUrl;
}
#pragma mark - NSCoding support
-(void)encodeWithCoder:(NSCoder*)encoder {
    
    [encoder encodeObject:self.path forKey:@"kneepath"];
    [encoder encodeObject:videoUrl forKey:@"videoUrl"];
    [encoder encodeObject:localVideoUrl forKey:@"localVideoUrl"];
}

-(id)initWithCoder:(NSCoder*)decoder {

    localVideoUrl = [decoder decodeObjectForKey:@"localVideoUrl"];
    path = [decoder decodeObjectForKey:@"kneepath"];
    videoUrl = [decoder decodeObjectForKey:@"videoUrl"];

    return self;
}

-(NSMutableDictionary *) getDictionary
{
    NSMutableDictionary *dictionary = [super getDictionary];
    if(self.s3Bucket)
    {
        [dictionary setObject:self.s3Bucket forKey:@"s3Bucket"];
    }
    if(self.s3Key)
    {
        [dictionary setObject:self.s3Key forKey:@"s3Key"];
    }
    return dictionary;
    
}


@end
