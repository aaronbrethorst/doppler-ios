//
//  herokuAppDelegate.h
//  heroku
//
//  Created by Aaron Brethorst on 7/22/10.
//  Copyright Structlab LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Heroku.h"

@class AccountsTableViewController, AppsTableViewController, HKTabBarController;

@interface herokuAppDelegate : NSObject <UIApplicationDelegate, HerokuDelegate>
{
    UIWindow *window;
	AccountsTableViewController *accounts;
	HKTabBarController *appTabs;
	UINavigationController *navigation;
	UISplitViewController *splitView;
	
	Heroku *heroku;
}
@property(nonatomic,retain) IBOutlet UIWindow *window;
- (void)deleteConsoleSession:(NSNotification*)note;
@end

