//
//  HeaderView.h
//  heroku
//
//  Created by Aaron Brethorst on 7/25/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GradientButton;

@interface HeaderView : UIView
{
	UITextField *textField;
}
@property(nonatomic,retain) UITextField *textField;
@end
