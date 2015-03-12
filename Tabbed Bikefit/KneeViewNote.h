//
//  KneeViewNote.h
//  bikefit
//
//  Created by Alfonso Lopez on 12/14/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FitNote.h"


@interface KneeViewNote : FitNote
{
    UIBezierPath *path;
    UIBezierPath *lazerPath;
    CGPoint startingPoint;
    NSURL *videoUrl;
    NSURL *localVideoUrl;
    NSString *s3Key;
    NSString *s3Bucket;
    
    int selectedFrameIndex;
}
+(NSString *)labelText;

@property (setter = setVideoUrl:, getter = getVideoUrl) NSURL *videoUrl;
@property UIBezierPath *path;
@property UIBezierPath *lazerPath;
@property CGPoint startingPoint;
@property NSString *s3Key;
@property NSString *s3Bucket;


@property int selectedFrameIndex;

- (UITableViewCell *) populateTableCell:(UITableViewCell *)cell;
@end
