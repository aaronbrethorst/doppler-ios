//
//  LoginViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 7/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewControllerDelegate.h"
#import "HKTableViewController.h"

@interface LoginViewController : HKTableViewController <UITextFieldDelegate>
{
	UITextField *usernameField;
	UITextField *passwordField;
	UISwitch *passwordSwitch;
	id<LoginViewControllerDelegate> __weak delegate;
}
@property(nonatomic,weak) id<LoginViewControllerDelegate> delegate;
+ (UINavigationController*)navigableLoginViewControllerWithDelegate:(id<LoginViewControllerDelegate>)delegate;
@end
