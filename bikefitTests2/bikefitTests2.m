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

#import "AmazonClientManager.h"

@interface SubcriptionManager (viewable)

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;

@end

@interface SubscriptionTests : XCTestCase <SubscriptionManagerDelegate>

@end

@implementation SubscriptionTests

XCTestExpectation *productsReturnedExpection;

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
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

- (void) testSuccessfulRestored {
    SubcriptionManager *sm = [SubcriptionManager sharedManager];
    sm.delegate = self;
    SKPaymentTransaction *transaction = [[SKPaymentTransaction alloc] init];
    
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(replaced_getTransactionState));
    Method originalMethod = class_getInstanceMethod([transaction class], @selector(transactionState));
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
    
    NSArray *transactions = [NSArray arrayWithObjects:transaction, nil];
    [sm paymentQueue:nil updatedTransactions:transactions];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isLoggedIn == True"];
    [self expectationForPredicate:predicate evaluatedWithObject:[AmazonClientManager credProvider]  handler:^BOOL{
        return true;
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        return;
    }];
}
    
- (SKPaymentTransactionState)replaced_getTransactionState
{
    return SKPaymentTransactionStateRestored;
}

#pragma Delegate Methods

- (void) productsReturned:(NSArray* _Nullable)products
{
    XCTAssertTrue([products count] > 0);
    SKProduct *product= products[0];
    XCTAssertTrue([[product productIdentifier] isEqualToString:@"pro_subscription"]);
    
    [productsReturnedExpection fulfill];
}


@end
