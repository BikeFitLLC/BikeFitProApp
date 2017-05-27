//
//  AWSSyncErrorManager.m
//  bikefit
//
//  Created by Max on 4/20/17.
//  Copyright © 2017 Alfonso Lopez. All rights reserved.
//

#import "AWSSyncErrorManager.h"

NSString * const kNotificationAWSSync = @"notificationAWSSync";

static NSString *const kPreferenceKeyErrorAthlete = @"preferenceKeyErrorAthlete";
@implementation AWSSyncErrorManager

+ (NSString * _Nullable)athleteWithError
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kPreferenceKeyErrorAthlete];
}

+ (void)setAthlete:(NSString * _Nonnull)athleteIdentifier hadSyncError:(BOOL)error
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (error) {
        [defaults setObject:athleteIdentifier forKey:kPreferenceKeyErrorAthlete];
    } else {
        [defaults removeObjectForKey:kPreferenceKeyErrorAthlete];
    }
    
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAWSSync
                                                        object:nil];
}

@end
