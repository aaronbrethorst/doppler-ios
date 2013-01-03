//
//  AccountsTableViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 7/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "AccountsTableViewController.h"
#import "AppsTableViewController.h"
#import "LoginViewController.h"

@interface AccountsTableViewController ()
- (void)pushAppsForUsername:(NSString*)username animated:(BOOL)yn;
@end

@implementation AccountsTableViewController

@synthesize detailViewController;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style
{
	if (self = [super initWithStyle:style])
	{
		self.title = NSLocalizedString(@"Accounts", @"");
	}
	return self;
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)] autorelease];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoSelectAccount:) name:@"LoadHerokuAccount" object:nil];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"last_account_used"])
	{
		[self pushAppsForUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"last_account_used"] animated:NO];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (0 == [[[HerokuCredentials sharedHerokuCredentials] usernames] count])
	{
		[self add:nil];
	}
}

#pragma mark -
#pragma mark NSNotificationCenter

- (void)autoSelectAccount:(NSNotification*)note
{
	[self.tableView reloadData];
	[self pushAppsForUsername:[note object] animated:YES];
}

#pragma mark -
#pragma mark LoginViewControllerDelegate

- (void)reloadCredentialsForUsername:(NSString*)username
{
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark IBActions

- (void)pushAppsForUsername:(NSString*)username animated:(BOOL)yn
{
	if (username)
	{
		[[NSUserDefaults standardUserDefaults] setObject:username forKey:@"last_account_used"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	AppsTableViewController *apps = [[[AppsTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	[detailViewController loadCredentials];
	apps.detailViewController = self.detailViewController;
	[self.navigationController pushViewController:apps animated:yn];
}

- (IBAction)add:(id)sender
{
	[self presentModalViewController:[LoginViewController navigableLoginViewControllerWithDelegate:self] animated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (0 == section)
	{
		return [[[HerokuCredentials sharedHerokuCredentials] usernames] count];
	}
	else
	{
		return 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}

	if (0 == indexPath.section)
	{
		cell.textLabel.text = [[[HerokuCredentials sharedHerokuCredentials] usernames] objectAtIndex:indexPath.row];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.textAlignment = UITextAlignmentLeft;
	}
	else
	{
		cell.textLabel.text = NSLocalizedString(@"Log Out All Accounts", @"");
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
	{
		[self pushAppsForUsername:[[[HerokuCredentials sharedHerokuCredentials] usernames] objectAtIndex:indexPath.row] animated:YES];
	}
	else
	{
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"")
														 message:NSLocalizedString(@"This will remove all of your Heroku passwords.",@"")
														delegate:self
											   cancelButtonTitle:NSLocalizedString(@"Cancel",@"")
											   otherButtonTitles:NSLocalizedString(@"OK",@""),nil] autorelease];
																				   
		[alert show];
		
		[tv deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return (0 == indexPath.section);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (UITableViewCellEditingStyleDelete == editingStyle && 0 == indexPath.section)
	{
		[[HerokuCredentials sharedHerokuCredentials] deleteUserAtIndex:indexPath.row];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}



#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (0 == buttonIndex)
	{
		//Cancel!
	}
	else
	{
		//Whack em!
		[[HerokuCredentials sharedHerokuCredentials] removeAllPasswords];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc
{
	RELEASE_SAFELY(detailViewController);
	[super dealloc];
}


@end

