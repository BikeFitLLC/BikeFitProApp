//
//  SubscriptionTests.m
//  bikefit
//
//  Created by Alfonso Lopez on 5/3/17.
//  Copyright © 2017 Alfonso Lopez. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SubcriptionManager.h"

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


#pragma Delegate Methods

- (void) productsReturned:(NSArray* _Nullable)products
{
    XCTAssertTrue([products count] > 0);
    [productsReturnedExpection fulfill];
}


@end
