//
//  AppDelegate.m
//  Tabbed Bikefit
//
//  Created by Alfonso Lopez on 5/31/13.
//  Copyright (c) 2013 Alfonso Lopez. All rights reserved.
//

#import "AppDelegate.h"
#import "AthletePropertyModel.h"
#import "BikefitConstants.h"

#import "AMZNGetAccessTokenDelegate.h"

#import <LoginWithAmazon/LoginWithAmazon.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //if we crashed last
    //if([[NSUserDefaults standardUserDefaults] objectForKey:@"lastemail"])
    //{
      //  [AthletePropertyModel loadAthleteFromAWS:[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITID_KEY]];
    //}
    
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTERID_KEY];
    //default to online mode on.
    /*
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_ONLINEMODE_KEY] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_DEFAULTS_ONLINEMODE_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    */
    
    //if online mode is on, try to get a token from amazon
    //if([[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_ONLINEMODE_KEY] boolValue])
    {
        AMZNGetAccessTokenDelegate* delegate = [[AMZNGetAccessTokenDelegate alloc] initWithParentController:nil];
        [AIMobileLib getAccessTokenForScopes:[NSArray arrayWithObject:@"profile"] withOverrideParams:nil delegate:delegate];
    }
    
    //Setup crash detection
    struct sigaction signalAction;
    memset(&signalAction, 0, sizeof(signalAction));
    signalAction.sa_handler = &HandleSignal;
    
    sigaction(SIGABRT, &signalAction, NULL);
    sigaction(SIGILL, &signalAction, NULL);
    sigaction(SIGBUS, &signalAction, NULL);
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // Pass on the url to the SDK to parse authorization code from the url.
    BOOL isValidRedirectLogInURL = [AIMobileLib handleOpenURL:url sourceApplication:sourceApplication];
    
    if(!isValidRedirectLogInURL)
        return NO;
    
    // App may also want to handle url
    return YES;
}

void HandleException(NSException *exception) {
    NSLog(@"App crashing with exception: %@", exception);
    //Save somewhere that your app has crashed.
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true]  forKey:@"crashRecovery"];
}

void HandleSignal(int signal) {
    NSLog(@"We received a signal: %d", signal);
    //Save somewhere that your app has crashed.
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"crashRecovery"];
}

@end
