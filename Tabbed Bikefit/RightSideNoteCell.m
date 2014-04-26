//
//  RightSideNoteCell.m
//  bikefit
//
//  Created by Alfonso Lopez on 3/3/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import "RightSideNoteCell.h"

@implementation RightSideNoteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
/*
-(void)LayoutSubviews
{
    base.LayoutSubviews ();
    imageView.Frame = new RectangleF(ContentView.Bounds.Width - 63, 5, 33, 33);
    headingLabel.Frame = new RectangleF(5, 4, ContentView.Bounds.Width - 63, 25);
    subheadingLabel.Frame = new RectangleF(100, 18, 100, 20);
}
*/
    
@end
