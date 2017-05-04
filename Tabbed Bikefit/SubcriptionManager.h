//
//  SubcriptionManager.h
//  bikefit
//
//  Created by Alfonso Lopez on 5/3/17.
//  Copyright © 2017 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Storekit/Storekit.h>

@interface SubcriptionManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>



@property SKMutablePayment* payment;
@property SKProductsRequest *request;
@property NSArray *products;
@property (nonatomic, copy) void (^success)();

+ (id)sharedManager;
- (void)retrieveAvailableProducts:(void (^)())success;
- (void) purchaseNewSubscription:(nonnull SKProduct*)product;


@end
