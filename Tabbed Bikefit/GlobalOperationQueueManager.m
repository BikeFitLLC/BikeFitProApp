//
//  GlobalOperationQueueManager.m
//  bikefit
//
//  Created by Alfonso Lopez on 4/25/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "GlobalOperationQueueManager.h"

@implementation GlobalOperationQueueManager
@synthesize queue;
- (id)init
{
    self = [super init];
    if (self)
    {
        queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

+ (GlobalOperationQueueManager *)queueManager
{
    static GlobalOperationQueueManager *sharedInstance = nil;
    static dispatch_once_t isDispatched;
    
    dispatch_once(&isDispatched, ^
        {
            sharedInstance = [[GlobalOperationQueueManager alloc] init];
        });
    
    return sharedInstance;
}
@end
