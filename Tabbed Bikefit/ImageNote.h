//
//  ImageNote.h
//  bikefit
//
//  Created by Alfonso Lopez on 4/25/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "FitNote.h"
#import "AmazonClientManager.h"

@interface ImageNote : FitNote //<AmazonServiceRequestDelegate>
{
    //NSURL *imageUrl;
    UIBezierPath *path;
    
    NSString *s3Key;
    NSString *s3Bucket;
}
@property(setter = setImage:, getter = getImage) NSData *image;
@property NSString *s3Key;
@property NSString *s3Bucket;

@property UIBezierPath *path;


-(NSMutableDictionary *) getDictionary;

//-(void)queueImageUpload;
//-(void) uploadImageToAws;
@end
