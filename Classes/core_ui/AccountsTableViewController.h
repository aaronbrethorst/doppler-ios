//
//  AccountsTableViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 7/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKTableViewController.h"
#import "LoginViewController.h"
#import "HerokuCredentials.h"
#import "HKTabBarController.h"

@interface AccountsTableViewController : HKTableViewController <LoginViewControllerDelegate, UIAlertViewDelegate>
{
	HKTabBarController *detailViewController;
}
@property(nonatomic,strong) HKTabBarController *detailViewController;
- (IBAction)add:(id)sender;
@end
