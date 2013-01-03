//
//  StructlabFullWidthTextFieldCell.h
//  FiveStar
//
//  Created by Aaron Brethorst on 6/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StructlabFullWidthTextFieldCell : UITableViewCell
{
	UITextField *textField;
}
+ (CGFloat)rowHeight;
@property (nonatomic, strong) UITextField *textField;
@end