//
//  AWSSyncErrorManager.h
//  bikefit
//
//  Created by Max on 4/20/17.
//  Copyright © 2017 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * _Nonnull const kNotificationAWSSync;
@interface AWSSyncErrorManager : NSObject

+ (NSString * _Nullable)athleteWithError;
+ (void)setAthlete:(NSString * _Nonnull)athleteIdentifier hadSyncError:(BOOL)error;

@end
