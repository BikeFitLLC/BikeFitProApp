//
//  SubscriptionTests.m
//  bikefit
//
//  Created by Alfonso Lopez on 5/3/17.
//  Copyright © 2017 Alfonso Lopez. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SubcriptionManager.h"

@interface SubscriptionTests : XCTestCase

@end

@implementation SubscriptionTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRetrieveProducts {
    SubcriptionManager *sm = [SubcriptionManager sharedManager];
    
    XCTestExpectation *retrieveReturned = [self expectationWithDescription:@"Retreive has come."];
    
    [sm retrieveAvailableProducts:^{
        [retrieveReturned fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
        XCTAssertTrue([sm.products count] == 1);
        SKProduct* product = sm.products[0];
        XCTAssertTrue([product.productIdentifier isEqualToString:@"pro_subscription"]);
    }];
    
}

- (void)testPurchaseSubscription {
    
    XCTestExpectation *retrieveReturned = [self expectationWithDescription:@"Retreive has come."];
    
    SubcriptionManager *sm = [SubcriptionManager sharedManager];
    
    [sm retrieveAvailableProducts:^{
        [retrieveReturned fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
        [sm purchaseNewSubscription:sm.products[0]];
    }];
}




@end
