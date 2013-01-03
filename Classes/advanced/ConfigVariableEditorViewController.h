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
	id<ConfigVariableDelegate> __weak delegate;
}
@property(nonatomic,weak) id<ConfigVariableDelegate> delegate;
@property(nonatomic,strong) App *app;
@property(nonatomic,strong) NSString *configVariableKey;
@property(nonatomic,strong) NSString *configVariableValue;
+ (UINavigationController*)navigableControllerWithApp:(App*)app key:(NSString*)key value:(NSString*)value delegate:(id<ConfigVariableDelegate>)delegate;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@end
