//
//  SubcriptionManager.m
//  bikefit
//
//  Created by Alfonso Lopez on 5/3/17.
//  Copyright © 2017 Alfonso Lopez. All rights reserved.
//

#import "SubcriptionManager.h"
#import "AmazonClientManager.h"
#import "BikefitConstants.h"


#import "AFNetworking.h"

#define BF_IN_APP_COMPLETE @"inAppPurchaseValid"

@interface SubcriptionManager()

@property (nonnull, strong) SKMutablePayment* payment;
@property (nonnull, strong) SKProductsRequest *request;
@property (nonatomic, strong) UserInfo* userInfo;

@end

@implementation SubcriptionManager
@synthesize products;

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
/*
 * Calls in-app purchase to subscribe and  will eventually create a new account
 * on success.
 */
-(void) purchaseNewSubscription:(nonnull SKProduct*) product
{
    __weak __typeof__(self) weakSelf = self;
    if( ![AmazonClientManager verifyLoggedIn] ) {
        //TODO: we only allow purchases for logged in accounts.
        //send an error or do something..the UI should not allow this.
        NSLog(@"Cannot purchase new subscription if you aren't logged in");
    }
    
    [self validateReceipt:^(BOOL valid) {
        if(valid) {
            NSLog(@"Purchase attempted for account that already has a reciept");
            //TODO link this reciept and the logged in user.
        } else {
            //TODO: expired receipt should probably not trigger a new purchase...
            self.payment = [SKMutablePayment paymentWithProduct:product];
            //TODO: HASH the user name.
            self.payment.applicationUsername = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_USERNAME_KEY];
            NSLog(@"Adding payment to storekit queue");
            [[SKPaymentQueue defaultQueue] addPayment:self.payment];
        }
    } failure:^(NSError *error) {
        //TODO: Go ahead and make the purchase?
        NSLog(@"Error validateing reciept");
    }];

}

/*
 * Loads and Returns available products
 * TODO: Add validation?
 */
- (void)retrieveAvailableProducts
{
    if(self.products && [self.delegate respondsToSelector:@selector(productsReturned)])
    {
        [self.delegate productsReturned:self.products];
    }
    
    NSArray *productIdentifiers = [NSArray arrayWithObjects:@"pro_subscription", nil];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    
    // Keep a strong reference to the request.
    self.request = productsRequest;
    productsRequest.delegate = self;
    
    NSLog(@"Sending productsRequest to Apple");
    [productsRequest start];
}

#pragma mark private
/*
 * Get the reciept.  This is broken out for testing purposes
 */

- (NSString*) getReceipt {
    NSURL* url = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:url];
    return [receiptData base64EncodedStringWithOptions:0];
}

/*
 * Find the current reciept and trys to validate it
 */
- (void) validateReceipt:(void (^)(BOOL valid))success failure:(void (^)(NSError *error))failure {
    
    //
    // Get and decode Receipt data
    //
    NSString* receipt = [self getReceipt];
    if( receipt == nil ) {
        NSLog(@"No Reciept Found, returning invalid");
        success(NO);
        return;
    }
    
    //
    // Send Reciept to the TVM for validation
    //
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:receipt, @"receipt-data", nil];
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                          URLString:[NSString stringWithFormat:@"%@/validateReciept", TVM_HOSTNAME]
                                                                         parameters:parameters
                                                                              error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request
                                                completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                    if( error ) {
                                                        NSLog(@"Error: %@", error);
                                                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:false] forKey:BF_IN_APP_COMPLETE];
                                                        failure(error);
                                                    } else {
                                                        NSLog(@"Successfully validated reciept with TVM");
                                                        NSDictionary* responseDict = responseObject;
                                                        //
                                                        // Iterate through all the purchases returned by apple
                                                        // if an expiration date is later than today, we are vood
                                                        // to enable subscription features
                                                        //
                                                        for( NSDictionary* purchase in responseDict[@"latest_receipt_info"]) {
                                                            //Create an expiration date from the string returne by apple
                                                            NSString* expiresDateString =[purchase[@"expires_date"] stringByReplacingOccurrencesOfString:@"Etc/GMT" withString:@"GMT"];
                                                            NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                                            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
                                                            NSDate* expirationDate = [df dateFromString:expiresDateString];
                                                            
                                                            // If Now is later than the date, this is not an unexpired purchase,
                                                            // SO keep going, otherwise the receipt is up to date and we are done.
                                                            if( [expirationDate timeIntervalSinceNow] > 0 ) {
                                                                NSLog(@"Receipt is up to date");
                                                                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:BF_IN_APP_COMPLETE];
                                                                success(true);
                                                                return;
                                                            }
                                                        }
                                                        // Nothing in the currently validate receipt has an unexpired
                                                        // so call failure.
                                                        NSError* error = [NSError errorWithDomain:@"Bikefit Error"
                                                                                            code:1
                                                                                         userInfo:@{@"description":@"No Active Renewals"}];
                                                        NSLog(@"Error with tvm-validated reciept: %@", error);
                                                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:false] forKey:BF_IN_APP_COMPLETE];
                                                        success(false);
                                                    }}];
    [dataTask resume];
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
    
    if([self.delegate respondsToSelector:@selector(productsReturned:)])
    {
        [self.delegate productsReturned:self.products];
    }
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
                NSLog(@"Transaction Failed: %@", [transaction.error localizedDescription]);
                [queue finishTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchased:
                [self handleTransactionStatePurchased:transaction];
                [queue finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [queue finishTransaction:transaction];
                break;
            default:
                // For debugging
                NSLog(@"Unexpected transaction state %@", @(transaction.transactionState));
                break;
        }
    }
}


- (void) handleTransactionStatePurchased:(SKPaymentTransaction*)transaction {
    NSLog(@"Purchase completed for user %@", transaction.payment.applicationUsername);
    if(! [transaction.payment.applicationUsername isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_USERNAME_KEY]] ) {
        //if this transaction is not for the currently logged in user, do nothing.
        //TODO: call delegate?  I thhink so...
        return;
    }
    
    //TODO: add original transaction ID to teh database.
    [_delegate purchaseComplete:nil];
    
}

@end
