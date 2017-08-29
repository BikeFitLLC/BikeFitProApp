//
//  SubcriptionManager.h
//  bikefit
//
//  Created by Alfonso Lopez on 5/3/17.
//  Copyright © 2017 Alfonso Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Storekit/Storekit.h>
#import "UserInfo.h"

@protocol SubscriptionManagerDelegate <NSObject>

@required
- (void) productsReturned:(NSArray* _Nullable)products;
- (void) purchaseComplete:(NSError* _Nullable) error;
//- (void) restoreComplete:(NSError* _Nullable) error;

@end

@interface SubcriptionManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonnull, strong) NSArray *products;
@property (atomic, strong) id<SubscriptionManagerDelegate> _Nullable delegate;

+ (SubcriptionManager* _Nonnull)sharedManager;
- (void) retrieveAvailableProducts;
- (void) purchaseNewSubscription:(nonnull SKProduct*)product;
- (void) checkForCompletedTransaction;

@end
