//
//  FitterEndpointClient.h
//  bikefit
//
//  Created by Alfonso Lopez on 6/21/17.
//  Copyright © 2017 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"

typedef void (^GetFitterCompletion)(UserInfo*, NSError*);

@interface FitterEndpointClient : NSObject

+ (id)sharedClient;

- (void) getFitterInfo:(NSString*)fitterid completionBlock:(GetFitterCompletion)completion;
- (void) putFitterInfo:(NSString*)fitterid fitterInfo:(UserInfo*)fitterInfo completionBlock:(GetFitterCompletion)completion;

@end
