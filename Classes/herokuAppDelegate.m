//
//  herokuAppDelegate.m
//  heroku
//
//  Created by Aaron Brethorst on 7/22/10.
//  Copyright Structlab LLC 2010. All rights reserved.
//

#import "herokuAppDelegate.h"
#import "AccountsTableViewController.h"
#import "HKTabBarController.h"
#import "HerokuCredentials.h"

@implementation herokuAppDelegate

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[HerokuCredentials sharedHerokuCredentials] firstLaunch15CredentialNuke];

     heroku = nil;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteConsoleSession:) name:@"DeleteConsoleSession" object:nil];
	
	if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
	{
		accounts = [[AccountsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
		navigation = [[UINavigationController alloc] initWithRootViewController:accounts];
		
		appTabs = [[HKTabBarController alloc] initWithNibName:@"HKTabBarController-iPad" bundle:nil];
		accounts.detailViewController = appTabs;
		
		splitView = [[UISplitViewController alloc] init];
		splitView.viewControllers = [NSArray arrayWithObjects:navigation,[[UINavigationController alloc] initWithRootViewController:appTabs], nil];
		splitView.delegate = appTabs;
		
		[window addSubview:splitView.view];
	}
	else
	{
		accounts = [[AccountsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
		navigation = [[UINavigationController alloc] initWithRootViewController:accounts];
		
		[window addSubview:navigation.view];
	}	

    [window makeKeyAndVisible];
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteConsoleSession:) name:@"DeleteConsoleSession" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteConsoleSession:) name:@"DeleteConsoleSession" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark NSNotifications

- (void)deleteConsoleSession:(NSNotification*)note
{
	if (nil == heroku)
	{
		heroku = [[Heroku alloc] init];
	}

	heroku.username = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_account_used"];
	heroku.apiKey = [[HerokuCredentials sharedHerokuCredentials] passwordForUsername:heroku.username];
    [[HerokuAPIClient sharedClient] setAuthorizationHeaderWithUsername:heroku.username password:heroku.apiKey];
	
	NSString *consoleID = [[note object] objectForKey:@"ConsoleID"];
	NSString *appName = [[note object] objectForKey:@"AppName"];
	
	[heroku deleteConsole:consoleID forApp:appName];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	//Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
}




@end
