//
//  GlobalOperationQueueManager.h
//  bikefit
//
//  Created by Alfonso Lopez on 4/25/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlobalOperationQueueManager : NSObject
{
    NSOperationQueue *queue;
}

@property NSOperationQueue *queue;


+ (GlobalOperationQueueManager *)queueManager;
@end
