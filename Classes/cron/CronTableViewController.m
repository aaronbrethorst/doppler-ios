    //
//  CronTableViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 7/26/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "CronTableViewController.h"
#import "LogsViewController.h"

@interface CronTableViewController ()
- (void)populateTable;
@end


@implementation CronTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self populateTable];
}

- (void)populateTable
{
	if (nil == self.app.cronNextRun && nil == self.app.cronFinishedAt)
	{
		HKTableSection* section = [HKTableSection sectionWithTitle:@"Cron is not configured."];
		[self.appDetails addObject:section];
	}
	else
	{
		HKTableSection* section = [HKTableSection sectionWithTitle:@"Cron"];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterShortStyle];
		[formatter setTimeStyle:NSDateFormatterShortStyle];
		
		if (self.app.cronNextRun)
		{
			[section.rows addObject:[HKTableRow rowWithTitle:@"Next run" value:[formatter stringFromDate:self.app.cronNextRun] target:nil action:nil]];
		}
		if (self.app.cronFinishedAt)
		{
			[section.rows addObject:[HKTableRow rowWithTitle:@"Last finished" value:[formatter stringFromDate:self.app.cronFinishedAt] target:nil action:nil]];
		}
		
		[section.rows addObject:[HKTableRow rowWithTitle:@"Logs" value:nil target:self action:@selector(cronLogs:)]];
		[self.appDetails addObject:section];
	}
	
	[self.tableView reloadData];
}


- (IBAction)cronLogs:(id)sender
{
	LogsViewController *logs = [[LogsViewController alloc] init];
	logs.herokuSelector = @selector(cronLogs:);
	logs.app = self.app;
	logs.title = NSLocalizedString(@"Cron Logs",@"");
	[self.parent.navigationController pushViewController:logs animated:YES];
}


@end
