//
//  SubcriptionManager.m
//  bikefit
//
//  Created by Alfonso Lopez on 5/3/17.
//  Copyright © 2017 Alfonso Lopez. All rights reserved.
//

#import "SubcriptionManager.h"

@implementation SubcriptionManager

#pragma mark Singleton
+ (id)sharedManager {
    static SubcriptionManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

#pragma mark subscription calls
-(void) purchaseNewSubscription:(nonnull SKProduct*)product
{
    self.payment = [SKMutablePayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:self.payment];
}

- (void)retrieveAvailableProducts:(void (^)())success
{
    if(self.products)
    {
        success();
        return;
    }
    
    self.success = success;
    NSArray *productIdentifiers = [NSArray arrayWithObjects:@"pro_subscription", nil];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    
    // Keep a strong reference to the request.
    self.request = productsRequest;
    productsRequest.delegate = self;
    
    NSLog(@"Sending productsRequest to Apple");
    [productsRequest start];
}

// SKProductsRequestDelegate protocol method
- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"ProductsRequest Response Recieved");
    self.products = response.products;
    
    for (NSString *invalidIdentifier in response.invalidProductIdentifiers) {
        NSLog(@"StoreKit: Invalid product found: %@", invalidIdentifier);
    }
    self.success();
    return;
}

#pragma Mark Transaction Observer
- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                // Call the appropriate custom method for the transaction state.
            case SKPaymentTransactionStatePurchasing:
//                [self showTransactionAsInProgress:transaction deferred:NO];
                break;
            case SKPaymentTransactionStateDeferred:
//                [self showTransactionAsInProgress:transaction deferred:YES];
                break;
            case SKPaymentTransactionStateFailed:
//                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchased:
//                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
//                [self restoreTransaction:transaction];
                break;
            default:
                // For debugging
                NSLog(@"Unexpected transaction state %@", @(transaction.transactionState));
                break;
        }
    }
}

@end
