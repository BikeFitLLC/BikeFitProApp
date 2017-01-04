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
    UITableView *dimensionsTable;
    
    UIImageView *bikeDimensionsImageView;
    NSArray *bikeDimensionsImages;
    int activeBikeImageIndex;
    
    UIView *propertyEditView;
    UILabel *propertyNameLabel;
    UILabel *millimeterLabel;
    UITextField *propertyValueField;
    
    NSMutableArray *dimensionsFieldNames;
    NSMutableArray *dimensionsFieldNames1;
    NSMutableArray *dimensionsFieldNames2;
    NSArray *hardwareFieldNames;
    
    NSMutableDictionary *fieldNameDict;
}

@end
