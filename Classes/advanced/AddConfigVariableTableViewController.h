//
//  AddConfigVariableTableViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 8/9/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKTableViewController.h"
#import "ConfigVariableDelegate.h"

@class App;

@interface AddConfigVariableTableViewController : HKTableViewController <UITextFieldDelegate>
{
	App *app;
	
	UITextField *key;
	UITextField *value;
	
	id<ConfigVariableDelegate> delegate;
}
@property(nonatomic,assign) id<ConfigVariableDelegate> delegate;
@property(nonatomic,retain) App *app;
@property(nonatomic,retain) UITextField *key;
@property(nonatomic,retain) UITextField *value;
+ (UINavigationController*)navigableControllerWithApp:(App*)app delegate:(id<ConfigVariableDelegate>)delegate;
@end
