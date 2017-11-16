//
//  FitterEndpointClient.m
//  bikefit
//
//  Created by Alfonso Lopez on 6/21/17.
//  Copyright © 2017 Alfonso Lopez. All rights reserved.
//

#import "FitterEndpointClient.h"
#import "AFNetworking.h"
#import "BikefitConstants.h"

//TODO: make all calls to the web include app version and ios info and stuff like that.
@implementation FitterEndpointClient

#pragma mark Singleton
+ (id)sharedClient {
    static FitterEndpointClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] init];
    });
    return sharedClient;
}


- (void) getFitterInfo:(NSString*)fitterid completionBlock:(GetFitterCompletion)completion {
    //TODO: make this a static class variable
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:[NSString stringWithFormat:@"%@/fitter/%@", BF_WEB_API_HOSTNAME, fitterid]
                                                                                parameters:nil
                                                                                     error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request
                                                completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                    if(error) {
                                                        //TODO: handle this case
                                                        return;
                                                    } else {
                                                        UserInfo* returnedUser = [UserInfo userInfoWithEmail:responseObject[@"FitterEmail"]
                                                                                                   firstName:nil
                                                                                                    lastName:nil
                                                                                                    password:nil
                                                                                                    shopName:responseObject[@"Name"]
                                                                                                    fitterid:responseObject[@"FitterID"]
                                                                                               transactionid:responseObject[@"TransactionID"]];
                                                        completion(returnedUser, nil);
                                                    }
                                                }];
    [dataTask resume];
}


- (void) putFitterInfo:(NSString*)fitterid fitterInfo:(UserInfo*)fitterInfo completionBlock:(GetFitterCompletion)completion {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"PUT"
                                                                                 URLString:[NSString stringWithFormat:@"%@/fitter/%@", BF_WEB_API_HOSTNAME, fitterid]
                                                                                parameters:nil
                                                                                     error:nil];
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[fitterInfo getPropertyDictionary]
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    //TODO check error
    [request setHTTPBody: jsonData];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request
                                                completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                    completion(nil, error);
                                                }];
    [dataTask resume];
}


- (void) getFitterIDForOriginalTransactionID:(NSString*)originalTransactionID {
    //Need implement the endpoint for this.
}
@end
