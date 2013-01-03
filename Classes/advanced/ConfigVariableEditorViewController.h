//
//  ConfigVariableEditorViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 8/9/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKTableViewController.h"
#import "App.h"
#import "ConfigVariableDelegate.h"

@interface ConfigVariableEditorViewController : HKTableViewController <UITextFieldDelegate, UIAlertViewDelegate>
{
	App *app;
	NSString *configVariableKey;
	NSString *configVariableValue;
	
	UITextField *valueField;
	id<ConfigVariableDelegate> delegate;
}
@property(nonatomic,assign) id<ConfigVariableDelegate> delegate;
@property(nonatomic,retain) App *app;
@property(nonatomic,retain) NSString *configVariableKey;
@property(nonatomic,retain) NSString *configVariableValue;
+ (UINavigationController*)navigableControllerWithApp:(App*)app key:(NSString*)key value:(NSString*)value delegate:(id<ConfigVariableDelegate>)delegate;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@end
