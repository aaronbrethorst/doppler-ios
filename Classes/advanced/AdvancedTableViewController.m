//
//  AdvancedTableViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 7/25/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "AdvancedTableViewController.h"
#import "RakeTableViewController.h"
#import "RunServiceViewController.h"
#import "LogsViewController.h"
#import "ConsoleViewController.h"
#import "ConfigVariablesTableViewController.h"
#import "ProcessesTableViewController.h"

@interface AdvancedTableViewController ()
- (void)populateTable;
@end


@implementation AdvancedTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self populateTable];
}

- (void)populateTable
{
	[self.appDetails removeAllObjects];
	
	HKTableSection* section = [HKTableSection sectionWithTitle:@"Advanced"];
	HKTableRow *rake = [HKTableRow rowWithTitle:@"Rake" value:nil target:self action:@selector(rake:)];
	rake.image = [UIImage imageNamed:@"tools_small.png"];
	[section.rows addObject:rake];

	HKTableRow *console = [HKTableRow rowWithTitle:@"Console" value:nil target:self action:@selector(console:)];
	console.image = [UIImage imageNamed:@"computer_small.png"];
	[section.rows addObject:console];
	
	HKTableRow *processes = [HKTableRow rowWithTitle:@"Processes" value:nil target:self action:@selector(processes:)];
	processes.image = [UIImage imageNamed:@"20-gear2.png"];
	[section.rows addObject:processes];
	
	HKTableRow *config = [HKTableRow rowWithTitle:@"Config Variables" value:nil target:self action:@selector(configVariables:)];
	config.image = [UIImage imageNamed:@"list_small.png"];
	[section.rows addObject:config];
	
	//[section.rows addObject:[HKTableRow rowWithTitle:@"Bundles" value:nil target:nil action:nil]];
	[self.appDetails addObject:section];
}

- (IBAction)rake:(id)sender
{
	RakeTableViewController *rake = [[RakeTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
	rake.app = self.app;
	[self.parent.navigationController pushViewController:rake animated:YES];
}

- (IBAction)console:(id)sender
{
	ConsoleViewController *console = [[ConsoleViewController alloc] init];
	console.app = self.app;
	[self.parent.navigationController pushViewController:console animated:YES];
}

- (IBAction)configVariables:(id)sender
{
	ConfigVariablesTableViewController *config = [[ConfigVariablesTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
	config.app = self.app;
	[self.parent.navigationController pushViewController:config animated:YES];
}

- (IBAction)processes:(id)sender
{
	ProcessesTableViewController *ps = [[ProcessesTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
	ps.app = self.app;
	[self.parent.navigationController pushViewController:ps animated:YES];
}


@end

