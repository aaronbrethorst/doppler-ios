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
@property(nonatomic,strong) NSMutableArray *viewControllers;
@property(nonatomic,strong) NSMutableArray *tabBarItems;
@property(nonatomic,strong) IBOutlet UITabBar *tabBar;
@property(nonatomic,strong) IBOutlet UIView *tabContentView;
@property(nonatomic,strong) IBOutlet UIView *noAccounts;
@property(nonatomic,strong) IBOutlet UIButton *chooseApp;
@property(nonatomic,strong) IBOutlet UIButton *addButton;
@property(nonatomic,strong) IBOutlet UIView *chooseAppView;
@property(nonatomic,strong) UIViewController *selectedViewController;
@property(nonatomic,strong) App *app;

- (void)showError:(NSString*)message;
- (void)loadData;
- (void)loadCredentials;
- (IBAction)addAccount:(id)sender;
- (IBAction)chooseApp:(id)sender;
@end