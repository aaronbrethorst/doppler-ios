//
//  AddonsTableViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 7/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "AddonsTableViewController.h"
#import "Heroku.h"
#import "WebViewController.h"
#import "NewRelicTableViewController.h"

@implementation AddonsTableViewController

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style
{
	if (self = [super initWithStyle:style])
	{
	}
	return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = self.app.name;
	
	[self loadData];
}

#pragma mark -
#pragma mark Heroku

- (void)loadData
{
	[super loadData];
	
	[self.heroku installedAddons:self.app.name];
}

- (void)herokuReceivedInstalledAddons:(id)obj
{
	[self hideLoadingUI];
	
	[self.appDetails removeAllObjects];
	
	HKTableSection *section = [HKTableSection sectionWithTitle:NSLocalizedString(@"Installed Addons",@"")];
	
	for (NSDictionary *dict in obj)
	{
		HKTableRow* row = [HKTableRow rowWithTitle:[dict objectForKey:@"description"] value:nil target:nil action:nil];
		
		if ([[dict objectForKey:@"name"] hasPrefix:@"newrelic"])
		{
			row.target = self;
			row.action = @selector(showNewRelic:);
		}
		else if ([dict objectForKey:@"url"] && ![[NSNull null] isEqual:[dict objectForKey:@"url"]])
		{
			row.target = self;
			row.action = @selector(showWebPage:);
			row.metadata = [dict objectForKey:@"url"];
		}
		
		[section.rows addObject:row];
	}
	
	[self.appDetails addObject:section];
	
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)showNewRelic:(id)sender
{
	NewRelicTableViewController *rpm = [[[NewRelicTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	rpm.parent = self.parent;
	rpm.app = self.app;
	[self deselectTableSelection];
	[self.parent.navigationController pushViewController:rpm animated:YES];
}

- (IBAction)showWebPage:(id)sender
{
	WebViewController *wvc = [[[WebViewController alloc] init] autorelease];
	wvc.URL = [NSURL URLWithString:[[sender metadata] description]];
	wvc.loadTitleFromDocument = YES;
	[self deselectTableSelection];
	[self.parent.navigationController pushViewController:wvc animated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}


- (void)dealloc
{
    [super dealloc];
}


@end

