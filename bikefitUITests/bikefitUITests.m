//
//  bikefitUITests.m
//  bikefitUITests
//
//  Created by Alfonso Lopez on 10/16/15.
//  Copyright © 2015 Alfonso Lopez. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface bikefitUITests : XCTestCase

@end

@implementation bikefitUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGoniometer {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.buttons[@"Please Log In"] tap];
    
    XCUIElement *passwordSecureTextField = app.secureTextFields[@"Password"];
    [passwordSecureTextField tap];
    [passwordSecureTextField typeText:@"password"];
    
    XCUIElement *emailTextField = app.textFields[@"Email"];
    [emailTextField tap];
    [emailTextField typeText:@"lebouf@gmail.com"];
    
    [app.buttons[@"Log In"] tap];
    
    [app.buttons[@"New Fit"] tap];
    [app.buttons[@"Basic Info"] tap];
    
    XCUIElement *athleteinfoNavigationBar = app.navigationBars[@"AthleteInfo"];
    [athleteinfoNavigationBar.buttons[@"Edit"] tap];
    
    XCUIElementQuery *tablesQuery = app.tables;
    XCUIElement *textField = [[tablesQuery.cells containingType:XCUIElementTypeButton identifier:@"Delete FirstName"] childrenMatchingType:XCUIElementTypeTextField].element;
    [textField tap];
    [textField typeText:@"First Name"];
    
    XCUIElement *textField2 = [[tablesQuery.cells containingType:XCUIElementTypeButton identifier:@"Delete LastName"] childrenMatchingType:XCUIElementTypeTextField].element;
    [textField2 tap];
    [textField2 tap];
    [textField2 typeText:@"LastName"];
    
    XCUIElement *textField3 = [[tablesQuery.cells containingType:XCUIElementTypeButton identifier:@"Delete Email"] childrenMatchingType:XCUIElementTypeTextField].element;
    [textField3 tap];
    [textField3 tap];
    [textField3 typeText:@"Email@email.com"];
    [athleteinfoNavigationBar.buttons[@"Done"] tap];
    
    
    ///////
    

    
    
    
}

@end
