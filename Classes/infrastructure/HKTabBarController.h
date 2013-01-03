//
//  HKTabBarController.h
//  heroku
//
//  Created by Aaron Brethorst on 7/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Heroku.h"
#import "LoginViewControllerDelegate.h"

@class App;

@interface HKTabBarController : UIViewController <MFMailComposeViewControllerDelegate, UITabBarDelegate, LoginViewControllerDelegate, HerokuDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate, UISplitViewControllerDelegate>
{
	NSMutableArray *viewControllers;
	UITabBar *tabBar;
	UIViewController *selectedViewController;
	UIView *tabContentView;
	
	NSMutableArray *tabBarItems;
	
	App *app;
	
	Heroku *heroku;

	UIPopoverController *popoverController;
	UIActionSheet *actionSheet;
	UIView *noAccounts;
	UIButton *chooseApp;
	UIButton *addButton;
	UIView *chooseAppView;
	
	BOOL receivedMemoryWarning;
}
@property(nonatomic,retain) NSMutableArray *viewControllers;
@property(nonatomic,retain) NSMutableArray *tabBarItems;
@property(nonatomic,retain) IBOutlet UITabBar *tabBar;
@property(nonatomic,retain) IBOutlet UIView *tabContentView;
@property(nonatomic,retain) IBOutlet UIView *noAccounts;
@property(nonatomic,retain) IBOutlet UIButton *chooseApp;
@property(nonatomic,retain) IBOutlet UIButton *addButton;
@property(nonatomic,retain) IBOutlet UIView *chooseAppView;
@property(nonatomic,retain) UIViewController *selectedViewController;
@property(nonatomic,retain) App *app;

- (void)showError:(NSString*)message;
- (void)loadData;
- (void)loadCredentials;
- (IBAction)addAccount:(id)sender;
- (IBAction)chooseApp:(id)sender;
@end