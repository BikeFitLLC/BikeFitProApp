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

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    SubcriptionManager *sm = [[SubcriptionManager alloc] init];
    [sm validateProductIdentifiers];
}



@end
