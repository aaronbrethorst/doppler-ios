//
//  AppsTableViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 7/22/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "AppsTableViewController.h"
#import "Heroku.h"
#import "HKTabBarController.h"
#import "WebViewController.h"

@implementation AppsTableViewController
@synthesize apps, detailViewController;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style])
	{
		self.title = NSLocalizedString(@"Heroku Apps", @"");
		self.apps = [NSArray array];
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	if ([self iPad])
	{
		self.clearsSelectionOnViewWillAppear = NO;
		self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	}

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadData)] autorelease];

	[self loadData];
}

#pragma mark -
#pragma mark Heroku

- (void)loadData
{
	[super loadData];
	[self.heroku list];
}

- (void)herokuReceivedList:(NSArray*)list
{
	self.apps = list;
	[self.tableView reloadData];
	[self hideLoadingUI];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.apps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];

		if (![self iPad])
		{
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}

	App *a = [self.apps objectAtIndex:indexPath.row];
	cell.textLabel.text = a.name;
	cell.detailTextLabel.text = a.domainName;

	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([self iPad])
	{
		[detailViewController loadCredentials];
		[detailViewController.navigationController popToRootViewControllerAnimated:NO];
		detailViewController.app = [self.apps objectAtIndex:indexPath.row];
	}
	else
	{
		HKTabBarController *hkTab = [[[HKTabBarController alloc] initWithNibName:@"HKTabBarController" bundle:nil] autorelease];
		hkTab.app = [self.apps objectAtIndex:indexPath.row];
		[[self navigationController] pushViewController:hkTab animated:YES];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload
{
	[super viewDidUnload];
}

- (void)dealloc
{
	RELEASE_SAFELY(detailViewController);

	self.apps = NULL;
	[super dealloc];
}

@end

