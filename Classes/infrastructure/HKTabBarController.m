//
//  HKTabBarController.m
//  heroku
//
//  Created by Aaron Brethorst on 7/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "HKTabBarController.h"
#import "App.h"
#import "AppDetailsTableViewController.h"
#import "LoginViewController.h"
#import "HKTableSection.h"
#import "NSString+Additions.h"
#import "AddonsTableViewController.h"
#import "HomeTableViewController.h"
#import "UsersTableViewController.h"
#import "AdvancedTableViewController.h"
#import "CronTableViewController.h"
#import "WebViewController.h"
#import "LoginViewController.h"
#import "RakeTableViewController.h"
#import "ConsoleViewController.h"
#import "ProcessesTableViewController.h"
#import "ConfigVariablesTableViewController.h"

@interface HKTabBarController ()
- (void)createHomeViewController;
- (void)createUsersViewController;
- (void)createAddonsViewController;
- (void)createCronViewController;
- (void)createAdvancedViewController;

- (CGRect)centeredRectForView:(UIView*)v;
- (void)configureViewController:(id)vc title:(NSString*)aTitle imageName:(NSString*)imageName tag:(int)tag;
- (void)showMessage:(NSString*)message withTitle:(NSString*)title;
- (void)composeEmailWithSubject:(NSString*)subject toRecipients:(NSArray*)recipients body:(NSString*)body;
//iPad
@property (nonatomic, retain) UIPopoverController *popoverController;
@end

@implementation HKTabBarController

@synthesize viewControllers, tabBar, selectedViewController, tabContentView, noAccounts, chooseApp, chooseAppView, addButton, tabBarItems;
@synthesize app;

@synthesize popoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		heroku = [[Heroku alloc] init];
		heroku.delegate = self;
		[self loadCredentials];
		receivedMemoryWarning = NO;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions",@"")
											  delegate:self
									 cancelButtonTitle:@"Cancel"
								destructiveButtonTitle:nil
									 otherButtonTitles:@"Restart Server", @"Maintenance Mode On", @"Maintenance Mode Off", nil];
	
	if (IS_IPAD())
	{
		UIImage *stretchy = [[UIImage imageNamed:@"button_bg.png"] stretchableImageWithLeftCapWidth:22.0f topCapHeight:22.0f];
		[self.addButton setBackgroundImage:stretchy forState:UIControlStateNormal];
		[self.chooseApp setBackgroundImage:stretchy forState:UIControlStateNormal];
	}
	
	if (receivedMemoryWarning)
	{
		receivedMemoryWarning = NO;
		[self loadData];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (IS_IPAD() && nil == self.app)
	{
		if ([[HerokuCredentials sharedHerokuCredentials] isEmpty])
		{
			CGRect f = CGRectMake((self.tabContentView.frame.size.width - self.noAccounts.frame.size.width) / 2.0f,
					   (self.tabContentView.frame.size.height - self.noAccounts.frame.size.height) / 2.0f,
					   self.noAccounts.frame.size.width,
					   self.noAccounts.frame.size.height);
			self.noAccounts.frame = f;
			[self.tabContentView addSubview:self.noAccounts];
		}
		else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
		{
			self.chooseAppView.frame = [self centeredRectForView:self.chooseAppView];
			[self.tabContentView addSubview:self.chooseAppView];
		}
	}
}

- (CGRect)centeredRectForView:(UIView*)v
{
	double x = floor((self.tabContentView.frame.size.width - v.frame.size.width) / 2.0f);
	double y = floor((self.tabContentView.frame.size.height - v.frame.size.height) / 2.0f);
	return CGRectMake(x, y, v.frame.size.width, v.frame.size.height);
}

- (void)loadData
{
	[self showLoadingUI];
	[heroku info:self.app.name];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
	receivedMemoryWarning = YES;
	
	self.tabBar = NULL;
	self.viewControllers = NULL;
	self.selectedViewController = NULL;
	self.popoverController = NULL;
	self.noAccounts = NULL;
	self.chooseApp = NULL;
	self.chooseAppView = NULL;
	self.addButton = NULL;
	RELEASE_SAFELY(actionSheet);
	[super viewDidUnload];
}

- (void)setApp:(App *)a
{
	[a retain];
	[app release];
	app = a;
	
	if (app)
	{
		if (nil != popoverController)
		{
			[popoverController dismissPopoverAnimated:YES];
		}
        
		self.title = app.name;
		[self loadData];
	}	
}

#pragma mark -
#pragma mark LoginViewController

- (void)loadCredentials
{
	NSString *u = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_account_used"];
	NSString *p = [[HerokuCredentials sharedHerokuCredentials] passwordForUsername:u];
	heroku.username = u;
	heroku.apiKey = p;
    [[HerokuAPIClient sharedClient] setAuthorizationHeaderWithUsername:u password:p];
}

- (void)reloadCredentialsForUsername:(NSString*)username
{
	heroku.username = username;
	heroku.apiKey = [[HerokuCredentials sharedHerokuCredentials] passwordForUsername:username];
    [[HerokuAPIClient sharedClient] setAuthorizationHeaderWithUsername:heroku.username password:heroku.apiKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LoadHerokuAccount" object:username];
	self.noAccounts.hidden = YES;
	[popoverController presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)addAccount:(id)sender
{
	[self presentModalViewController:[LoginViewController navigableLoginViewControllerWithDelegate:self] animated:YES];
}

- (IBAction)chooseApp:(id)sender
{
	[popoverController presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc
{    
    barButtonItem.title = @"Apps";
	[self.navigationItem setLeftBarButtonItem:barButtonItem animated:NO];
    self.popoverController = pc;
	self.chooseAppView.hidden = NO;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
	[self.navigationItem setLeftBarButtonItem:NULL animated:NO];
    self.popoverController = nil;
	self.chooseAppView.hidden = YES;
}

#pragma mark -
#pragma mark Heroku

- (void)herokuReceivedInfo:(id)obj
{
	CXMLDocument *doc = [[CXMLDocument alloc] initWithXMLString:obj options:0 error:nil];
	[self.app populateWithAppXMLNode:[doc rootElement]];
	[doc release];
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionMenu:)] autorelease];
	
	self.viewControllers = [NSMutableArray array];
	self.tabBarItems = [NSMutableArray array];
	
	[self createHomeViewController];
	[self createUsersViewController];
	[self createAddonsViewController];
	[self createCronViewController];
	[self createAdvancedViewController];
	
	self.tabBar.items = self.tabBarItems;
	
	tabBar.selectedItem = [[tabBar items] objectAtIndex:0];
	[self tabBar:tabBar didSelectItem:tabBar.selectedItem];
	
	[self hideLoadingUI];
}

- (void)createHomeViewController
{
	HomeTableViewController *homeVC = [[[HomeTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	homeVC.parent = self;
	homeVC.app = self.app;
	[self.viewControllers addObject:homeVC];
	[self.tabBarItems addObject:[[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Home",@"") image:[UIImage imageNamed:@"home.png"] tag:0] autorelease]];
}

- (void)createUsersViewController
{
	UsersTableViewController *users = [[[UsersTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	users.app = self.app;
	users.parent = self;
	[self.viewControllers addObject:users];
	[self.tabBarItems addObject:[[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Users",@"") image:[UIImage imageNamed:@"users.png"] tag:1] autorelease]];
}

- (void)createAddonsViewController
{
	AddonsTableViewController *addons = [[[AddonsTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	addons.app = app;
	addons.parent = self;
	[self.viewControllers addObject:addons];
	[self.tabBarItems addObject:[[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Addons",@"") image:[UIImage imageNamed:@"switch.png"] tag:2] autorelease]];
}

- (void)createCronViewController
{
	CronTableViewController *cron = [[[CronTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	cron.app = self.app;
	cron.parent = self;
	[self.viewControllers addObject:cron];
	[self.tabBarItems addObject:[[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Cron",@"") image:[UIImage imageNamed:@"clock.png"] tag:3] autorelease]];
}

- (void)createAdvancedViewController
{
	if (IS_IPAD())
	{
		
		RakeTableViewController *rake = [[[RakeTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
		[self configureViewController:rake title:NSLocalizedString(@"Rake",@"")
							imageName:@"tools.png"
								  tag:4];
	
		ConsoleViewController *console = [[[ConsoleViewController alloc] init] autorelease];		
		[self configureViewController:console title:NSLocalizedString(@"Console",@"")
							imageName:@"computer.png"
								  tag:5];
		
		ProcessesTableViewController *ps = [[[ProcessesTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];		
		[self configureViewController:ps title:NSLocalizedString(@"Processes",@"")
							imageName:@"20-gear2.png"
								  tag:6];

		ConfigVariablesTableViewController *config = [[[ConfigVariablesTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
		[self configureViewController:config title:NSLocalizedString(@"Config Vars",@"")
							imageName:@"list.png"
								  tag:7];
	}
	else
	{
		AdvancedTableViewController *advanced = [[[AdvancedTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
		advanced.app = self.app;
		advanced.parent = self;
		[self.viewControllers addObject:advanced];
		[self.tabBarItems addObject:[[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:4] autorelease]];
	}
}

- (void)configureViewController:(id)vc title:(NSString*)aTitle imageName:(NSString*)imageName tag:(int)tag
{
	[vc setApp:self.app];
	[vc setParent:self];

	[self.viewControllers addObject:vc];
	[self.tabBarItems addObject:[[[UITabBarItem alloc] initWithTitle:aTitle image:[UIImage imageNamed:imageName] tag:tag] autorelease]];
}

- (void)dealloc
{
	RELEASE_SAFELY(popoverController);

	heroku.delegate = NULL;
	RELEASE_SAFELY(heroku);
	
	self.tabBarItems = NULL;

	self.app = NULL;
	[super dealloc];
}

#pragma mark -
#pragma mark UITabBarController

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	UIViewController *vc = [viewControllers objectAtIndex:item.tag];
	[vc viewWillAppear:YES];
	[self.selectedViewController.view removeFromSuperview];
	vc.view.frame = CGRectMake(0, 0, self.tabContentView.frame.size.width, self.tabContentView.frame.size.height);
	[self.tabContentView addSubview:vc.view];
	self.selectedViewController = vc;
	[vc viewDidAppear:YES];
}


- (void)showError:(NSString*)message
{
	[self showMessage:message withTitle:@"Error"];
}

- (void)showMessage:(NSString*)message withTitle:(NSString*)title
{
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[alert show];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)composeEmailWithSubject:(NSString*)subject toRecipients:(NSArray*)recipients body:(NSString*)body
{
	UIViewController *targetVC = ([self respondsToSelector:@selector(parent)] ? [self performSelector:@selector(parent)] : self);
	
	if ([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController *vc = [[[MFMailComposeViewController alloc] init] autorelease];
		vc.mailComposeDelegate = self;
		[vc setSubject:subject];
		[vc setToRecipients:recipients];
		
		if (body)
		{
			[vc setMessageBody:body isHTML:NO];
		}
		
		[targetVC presentModalViewController:vc animated:YES];
	}
	else
	{
		[self showError:@"Mail not configured. Please configure a mail account and try again."];
	}
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	UIViewController *targetVC = ([self respondsToSelector:@selector(parent)] ? [self performSelector:@selector(parent)] : self);
	
	switch (result)
	{
		case MFMailComposeResultSaved:
		{
			[targetVC dismissModalViewControllerAnimated:YES];
			[self showMessage:@"Your mail draft has been saved." withTitle:@"Draft Saved"];
			break;
		}
		case MFMailComposeResultFailed:
		{
			[self showError:@"Message failed to send"];
			break;
		}
		case MFMailComposeResultCancelled:
		case MFMailComposeResultSent:
		default:
		{
			[targetVC dismissModalViewControllerAnimated:YES];
			break;
		}
	}
}


#pragma mark -
#pragma mark HerokuDelegate

- (void)herokuError:(NSString*)errorMessage
{
    [self hideLoadingUI];
	[self showError:errorMessage];
}

- (void)herokuAuthenticationNeeded
{
	[self presentModalViewController:[LoginViewController navigableLoginViewControllerWithDelegate:self] animated:YES];
}

#pragma mark -
#pragma mark UIActionSheet

- (IBAction)showActionMenu:(id)sender
{
	if (IS_IPAD())
	{
		if (popoverController.popoverVisible)
		{
			[popoverController dismissPopoverAnimated:YES];
		}
		
		[actionSheet showFromBarButtonItem:sender animated:YES];
	}
	else
	{
		[actionSheet showFromTabBar:self.tabBar];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{	
	switch (buttonIndex)
	{
		case 0:
			[self showLoadingUI];
			[heroku restart:self.app.name];
			break;
		case 1:
		{
			[self showLoadingUI];
			[heroku changeMaintenanceMode:YES forApp:self.app.name];
			break;
		}
		case 2:
			[self showLoadingUI];
			[heroku changeMaintenanceMode:NO forApp:self.app.name];
			break;
		case 3:
			//Cancel
			break;
		default:
			break;
	}
}

- (void)herokuRestarted:(id)obj
{
	[self hideLoadingUI];
}

- (void)herokuMaintenanceModeChanged:(id)obj
{
	[NSTimer scheduledTimerWithTimeInterval:8.0f target:self selector:@selector(finalizeMaintenanceMode:) userInfo:nil repeats:NO];
}

- (void)finalizeMaintenanceMode:(NSTimer*)t
{
	WebViewController *wvc = [[[WebViewController alloc] init] autorelease];
	wvc.URL = [NSURL URLWithString:self.app.webURL];
	wvc.loadTitleFromDocument = YES;
	[self hideLoadingUI];
	[self.navigationController pushViewController:wvc animated:YES];
}

@end