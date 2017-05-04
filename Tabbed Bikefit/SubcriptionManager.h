//
//  SubcriptionManager.h
//  bikefit
//
//  Created by Alfonso Lopez on 5/3/17.
//  Copyright © 2017 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Storekit/Storekit.h>

@interface SubcriptionManager : NSObject <SKProductsRequestDelegate>

@property SKProductsRequest *request;
@property NSArray *products;

@end
