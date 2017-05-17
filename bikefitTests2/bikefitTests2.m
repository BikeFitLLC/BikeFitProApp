//
//  SubscriptionTests.m
//  bikefit
//
//  Created by Alfonso Lopez on 5/3/17.
//  Copyright © 2017 Alfonso Lopez. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Storekit/Storekit.h>
#import "SubcriptionManager.h"

#import <objc/runtime.h>
#include <stdlib.h>

#import "AmazonClientManager.h"

@interface SubcriptionManager (viewable)

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;

@end

@interface SubscriptionTests : XCTestCase <SubscriptionManagerDelegate, LoginDelegate>

@end

@implementation SubscriptionTests

XCTestExpectation *productsReturnedExpection;
XCTestExpectation *purchaseCompleteExpection;
XCTestExpectation *accountExistsExpection;

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testMakePurchase {
    SubcriptionManager *sm = [SubcriptionManager sharedManager];
    productsReturnedExpection = [self expectationWithDescription:@"Expected Products to be returned"];
    
    sm.delegate = self;
    [sm retrieveAvailableProducts];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        if(error){
            XCTFail(@"Failed to get products");
        }
    }];
    
    purchaseCompleteExpection = [self expectationWithDescription:@"Purchase Returned"];
    [sm purchaseNewSubscription:sm.products[0]];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            XCTFail(@"Failed to get products");
        }
    }];
    
}

- (void)testGetProducts {
    SubcriptionManager *sm = [SubcriptionManager sharedManager];
    productsReturnedExpection = [self expectationWithDescription:@"Expected Products to be returned"];
    
    sm.delegate = self;
    [sm retrieveAvailableProducts];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        if(error){
            XCTFail(@"Failed to get products");
        }
    }];
}

//- (void) testSuccessfulRestored {
//    SubcriptionManager *sm = [SubcriptionManager sharedManager];
//    sm.delegate = self;
//    SKPaymentTransaction *transaction = [[SKPaymentTransaction alloc] init];
//    
//    Method swizzledMethod = class_getInstanceMethod([self class], @selector(replaced_getTransactionState));
//    Method originalMethod = class_getInstanceMethod([transaction class], @selector(transactionState));
//    
//    method_exchangeImplementations(originalMethod, swizzledMethod);
//    
//    NSArray *transactions = [NSArray arrayWithObjects:transaction, nil];
//    sm.email = @"test@test.com";
//    sm.password = @"test";
//    [sm paymentQueue:nil updatedTransactions:transactions];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
//        return [AmazonClientManager verifyLoggedInActive];
//    }];
//    
//    [self expectationForPredicate:predicate evaluatedWithObject:self  handler:^BOOL{
//        return true;
//    }];
//    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
//        return;
//    }];
//}

- (SKPaymentTransactionState)replaced_getTransactionState
{
    return SKPaymentTransactionStateRestored;
}

- (void) testSuccessfulPurchased {
    SubcriptionManager *sm = [SubcriptionManager sharedManager];
    sm.delegate = self;
    
    SKPaymentTransaction *transaction = [[SKPaymentTransaction alloc] init];
    
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(replaced_getTransactionStatePurchased));
    Method originalMethod = class_getInstanceMethod([transaction class], @selector(transactionState));
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
    
    NSArray *transactions = [NSArray arrayWithObjects:transaction, nil];
    int r = arc4random_uniform(200);
    
    sm.email = [NSString stringWithFormat:@"test-%d@test.com", r];
    sm.password = @"test";
    [sm paymentQueue:nil updatedTransactions:transactions];
    
    purchaseCompleteExpection = [self expectationWithDescription:@"Purchase Completed"];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        return;
    }];
    
    accountExistsExpection  = [self expectationWithDescription:@"Account does exists"];
    [AmazonClientManager isAmazonAccount:sm.email andDelegate:self];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        return;
    }];
}

- (SKPaymentTransactionState)replaced_getTransactionStatePurchased
{
    return SKPaymentTransactionStatePurchased;
}


#pragma mark SubscriptionManager Delegate Methods

- (void) productsReturned:(NSArray* _Nullable)products
{
    XCTAssertTrue([products count] > 0);
    SKProduct *product= products[0];
    XCTAssertTrue([[product productIdentifier] isEqualToString:@"pro_subscription"]);
    
    [productsReturnedExpection fulfill];
}

- (void) purchaseComplete:(NSError *)error {
    [purchaseCompleteExpection fulfill];
}

#pragma mark Login Delegate
- (void)amazonCheckResult:(BOOL)isAmazonAccount accountExists:(BOOL)exists {
    if(exists) {
        [accountExistsExpection fulfill];
    }
}

- (void) onUserSignedIn {
    return;
}

@end
