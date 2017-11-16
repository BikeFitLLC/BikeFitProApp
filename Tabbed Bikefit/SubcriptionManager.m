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
#import "FitterEndpointClient.h"


#import "AFNetworking.h"

#define BF_IN_APP_COMPLETE @"inAppPurchaseValid"

@interface SubcriptionManager()

@property (nonnull, strong) SKMutablePayment* payment;
@property (nonnull, strong) SKProductsRequest *request;
@property (nonatomic, strong) UserInfo* userInfo;

//
// Completed Transactions that came back while the app is
// not logged in.  This will be checked on future logins.
//
@property (atomic, strong) NSMutableArray* completedTransactions;
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
    if( ![AmazonClientManager verifyLoggedIn] ) {
        //TODO: we only allow purchases for logged in accounts.
        //send an error or do something..the UI should not allow this.
        NSLog(@"Cannot purchase new subscription if you aren't logged in");
        return;
    }
    
    [self validateReceipt:^( BOOL valid, NSDictionary* purchase ) {
        if(valid) {
            NSLog(@"Purchase attempted for account that already has a reciept");
            //TODO link this reciept and the logged in user.
            
            //1. Get user from fitter endpoint that has the same original transactionid
            //2. Us they fitter info to message to the user?
            
            
            NSError* error = [NSError errorWithDomain:@"Bikefit Error"
                                                 code:1
                                             userInfo:@{@"description":@"AppleID Already Has BikeFit Account"}];
            [AmazonClientManager.credProvider clear]; //Logout the user...is this right?
            [_delegate purchaseComplete:error];
            return;
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
- (void) validateReceipt:(void (^)(BOOL valid, NSDictionary* mostRecentPurchase))success failure:(void (^)(NSError *error))failure {
    
    //
    // Get and decode Receipt data
    //
    NSString* receipt = [self getReceipt];
    if( receipt == nil ) {
        NSLog(@"No Reciept Found, returning invalid");
        success(NO, nil);
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
                                                                success(true, purchase);
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
                                                        success(false, nil);
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

/*
 * Checks to see if there is a completed transaction for the logged in user.  Meant to be
 * called after a new login, but technically could be called whenever.
 */
- (void) checkForCompletedTransaction {
    //TODO: check for logged in?
    //TODO: Verify the logged in account doesn't already have a transaction id
    NSString *fitterEmail = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_USERNAME_KEY];
    NSString *fitterid = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTERID_KEY];
    
    if( self.completedTransactions ) {
        for( SKPaymentTransaction *transaction in self.completedTransactions ) {
            if( [transaction.payment.applicationUsername isEqualToString:fitterEmail] ) {
                //
                //  Here we want to get the user info from the backend.  SO we do.  Then
                // we check for the transaction id and if it's not there, we add this transactions
                // id to the user on the DB.
                //
                // TODO: The credential provider should have already gotten the user info, addd that to
                // credential provider.
                //
                [[FitterEndpointClient sharedClient] getFitterInfo:fitterid completionBlock:^(UserInfo *userInfo, NSError *error) {
                    if( error ) {
                        NSLog(@"Error getting Fitter Info from backend: %@", error);
                    } else {
                        //TODO implement success!
                        if( userInfo.transactionid ) {
                            //TODO: this is a weird case...we alrady ahve a transaction id
                            // on the database, but a new completed purchase came through?
                            // This should not happen as it means we did multiple purchases for
                            // a single bikefit account.
                        } else {
                            //OK! Complete this transaction!
                            NSLog(@"Found completed transaction for the logged user. Email:%@", fitterEmail);
                            [self handleTransactionStatePurchased:transaction withPaymentQueue:[SKPaymentQueue defaultQueue]];
                        }
                        return;
                    }
                }];
            }
        }
    }
    
    if( fitterid ) {
        
    }
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
                [_delegate purchaseComplete:transaction.error];
                break;
            case SKPaymentTransactionStatePurchased:
                [self handleTransactionStatePurchased:transaction withPaymentQueue:(SKPaymentQueue*)queue];
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


- (void) handleTransactionStatePurchased:(SKPaymentTransaction*)transaction withPaymentQueue:(SKPaymentQueue*)queue {
    
    //TODO no point in doing this if we arent logged in?
    
    NSLog(@"Purchase completed for user %@", transaction.payment.applicationUsername);
    
    //TODO: IS this sufficient to know this user is ther right user?
    if(! [transaction.payment.applicationUsername isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_USERNAME_KEY]] ) {
        //TODO: call delegate?  I thhink so...
        NSLog(@"got completed trasnaction for user that is not logged in, saving for later logins");
        if( !self.completedTransactions ) {
            self.completedTransactions = [[NSMutableArray alloc] init];
        }
        [self.completedTransactions addObject:transaction];
        return;
    }
    NSString *fitterID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_FITTERID_KEY];
    //
    // Update the user record on the db with transaction id
    //
    
    // TODO: The below just takes the transaction id, for restored state we
    // might need to get original transaction id...but maybe not, now that I think about it...
    // Since this is not called for restore.  Make this comment justify the use of transactionidentifier.
    UserInfo* fitterInfo = [UserInfo userInfoWithEmail:nil
                                              firstName:nil
                                               lastName:nil
                                               password:nil
                                               shopName:nil
                                               fitterid:fitterID
                                          transactionid:transaction.originalTransaction.transactionIdentifier];
    [[FitterEndpointClient sharedClient] putFitterInfo:fitterID fitterInfo:fitterInfo completionBlock:^(UserInfo *fitterInfo, NSError *error) {
        [queue finishTransaction:transaction];
        [_delegate purchaseComplete:error];
    }];
}

@end
