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

@interface SubcriptionManager()

@property (nonnull, strong) SKMutablePayment* payment;
@property (nonnull, strong) SKProductsRequest *request;

@end

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
-(void) purchaseNewSubscription:(nonnull SKProduct*) product
{
    self.payment = [SKMutablePayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:self.payment];
}

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
//                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchased:
            {
                NSData *receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
                NSString *receipt = [receiptData base64EncodedStringWithOptions:0];
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
                    if (error) {
                        //
                        // Request from TVM came back with an Error
                        //
                        NSLog(@"Error: %@", error);
                        [_delegate purchaseComplete:error];
                    } else {
                        //
                        // Validation request succeeded, check status
                        // TODO: receipt checking?
                        //
                        NSLog(@"%@ %@", response, responseObject);
                        NSDictionary* responseDict = responseObject;
                        
                        if([responseDict[@"status"] integerValue] == 0) {
                            //
                            // Reciept Valid, Create a new account
                            //
                            [[AmazonClientManager credProvider] createNewAccountWithEmail:self.email
                                                                             password:self.password
                                                                             shopName:@"SubMan Test"
                                                                            firstName:@"SubMan Test"
                                                                             lastName:@"SubMan Test"
                                                                             callback:^(BOOL success) {
                                                                                 if(success) {
                                                                                     [_delegate purchaseComplete:nil];
                                                                                 } else {
                                                                                     NSError* error = [NSError errorWithDomain:@"SubscriptionManager" code:1 userInfo:@{@"description":@"Failed to create new acccount on bikefit backend"}];
                                                                                     [_delegate purchaseComplete:error];
                                                                                 }
                                                                             }];
                        } else {
                            //
                            // Reciept not valid, error!
                            //
                            NSError* error = [NSError errorWithDomain:@"SubscriptionManager"
                                                                 code:1
                                                             userInfo:@{@"description":@"Reciept Didn't Validate"}];
                            [_delegate purchaseComplete:error];
                        }
                    }
                }];
                [dataTask resume];
                
                
               
                break;
            }
            case SKPaymentTransactionStateRestored:
                //[_delegate restoreComplete:nil];
                break;
            default:
                // For debugging
                NSLog(@"Unexpected transaction state %@", @(transaction.transactionState));
                break;
        }
    }
}

@end
