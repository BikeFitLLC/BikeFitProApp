//
//  FinalNotesViewController.h
//  bikefit
//
//  Created by Alfonso Lopez on 9/22/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FinalNotesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate>
{
    
    /*
    UITextField *saddleHeightTextField;
    UITextField *saddleSetBacktextField;
    UITextField *handlebarDropTextField;
    UITextField *hoodDistanceTextField;
    UITextField *crankLengthTextField;
     */
    
    UITableView *dimensionsTable;
    UIImageView *bikeDimensionsImage;
    UIView *propertyEditView;
    UILabel *propertyNameLabel;
    UILabel *millimeterLabel;
    UITextField *propertyValueField;
    
    NSMutableArray *dimensionsFieldNames;
    NSArray *hardwareFieldNames;
    
    NSMutableDictionary *fieldNameDict;
}

@end
