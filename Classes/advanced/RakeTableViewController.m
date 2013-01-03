//
//  RakeTableViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 7/25/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "RakeTableViewController.h"
#import "RunServiceViewController.h"

@interface RakeTableViewController ()
- (void)populateTable;
- (NSString*)userDefaultsKey;
- (void)setupSearch;
@end


@implementation RakeTableViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self setupSearch];

	[self showLoadingUI];

	self.title = NSLocalizedString(@"Rake Tasks",@"");

	NSArray *savedTasks = [[NSUserDefaults standardUserDefaults] objectForKey:[self userDefaultsKey]];

	rakeTasks = [[NSMutableArray alloc] init];

	if (savedTasks)
	{
		[rakeTasks addObjectsFromArray:savedTasks];
		[self populateTable];
	}
	else
	{
		[self.heroku runService:@"rake -T" forApp:self.app.name];
	}
}

- (void)setupSearch
{
	searchResults = [[NSMutableArray alloc] init];

	UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)] autorelease];
	searchBar.delegate = self;
	[searchBar sizeToFit];
	self.tableView.tableHeaderView = searchBar;

	searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	searchDisplayController.delegate = self;
	searchDisplayController.searchResultsDataSource = self;
	searchDisplayController.searchResultsDelegate = self;
}

#pragma mark -
#pragma mark Heroku

- (void)herokuRunServiceFinished:(id)response
{
	NSArray *taskLines = [response componentsSeparatedByString:@"\n"];

	for (NSString *line in taskLines)
	{
		NSArray *parts = [line componentsSeparatedByString:@"#"];

		if (2 == [parts count])
		{
			NSString *task = [[parts objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			NSString *description = [[parts objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

			[rakeTasks addObject:[NSDictionary dictionaryWithObjectsAndKeys:task, kTaskName, description, kTaskDescription,nil]];
		}
	}

	[[NSUserDefaults standardUserDefaults] setObject:rakeTasks forKey:[self userDefaultsKey]];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[self populateTable];
}

- (void)populateTable
{
	HKTableSection *section = [HKTableSection sectionWithTitle:@"Rake Tasks"];

	for (NSDictionary *dict in rakeTasks)
	{
		[section.rows addObject:[HKTableRow rowWithTitle:[dict objectForKey:kTaskName]
												   value:[dict objectForKey:kTaskDescription]
												  target:self
												  action:@selector(performTask:)
												   style:UITableViewCellStyleSubtitle]];
	}
	[self.appDetails addObject:section];

	[self hideLoadingUI];

	[self.tableView reloadData];
}

#pragma mark -
#pragma Table Data Source and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (tableView == searchDisplayController.searchResultsTableView)
	{
		return 1;
	}
	else
	{
		return [self.appDetails count];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == searchDisplayController.searchResultsTableView)
	{
		return [searchResults count];
	}
	else
	{
		return [[self.appDetails objectAtIndex:section] count];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (tableView == searchDisplayController.searchResultsTableView)
	{
		return nil;
	}
	else
	{
		HKTableSection *tsec = [self.appDetails objectAtIndex:section];
		return tsec.title;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == searchDisplayController.searchResultsTableView)
	{
		static NSString *searchIdentifier = @"SearchIdentifier";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchIdentifier];
		if (nil == cell)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:searchIdentifier] autorelease];
		}
		NSDictionary *dict = [searchResults objectAtIndex:indexPath.row];
		cell.textLabel.text = [dict objectForKey:kTaskName];
		cell.detailTextLabel.text = [dict objectForKey:kTaskDescription];
		return cell;
	}
	else
	{
		return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == searchDisplayController.searchResultsTableView)
	{
		NSDictionary *dict = [searchResults objectAtIndex:indexPath.row];
		RunServiceViewController *run = [[[RunServiceViewController alloc] init] autorelease];
		run.app = self.app;
		run.serviceCommand = [dict objectForKey:kTaskName];
		run.title = NSLocalizedString(@"Rake Task",@"");
		[self.navigationController pushViewController:run animated:YES];
	}
	else
	{
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}

#pragma mark -
#pragma mark Search

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	[searchResults removeAllObjects];

	NSString *lower = [searchString lowercaseString];

	for (NSDictionary *d in rakeTasks)
	{
		if ([[[d objectForKey:kTaskName] lowercaseString] rangeOfString:lower].length > 0 || [[[d objectForKey:kTaskDescription] lowercaseString] rangeOfString:lower].length > 0)
		{
			[searchResults addObject:d];
		}
	}

	return YES;
}

#pragma mark -
#pragma mark IBActions

- (void)performTask:(id)sender
{
	HKTableRow *row = sender;
	RunServiceViewController *run = [[[RunServiceViewController alloc] init] autorelease];
	run.app = self.app;
	run.serviceCommand = row.title;
	run.title = NSLocalizedString(@"Rake Task",@"");

    if ([self iPad])
    {
        [[[self parent] navigationController] pushViewController:run animated:YES];
    }
    else
    {
        [self.navigationController pushViewController:run animated:YES];
    }

}

#pragma mark -
#pragma mark Misc

- (NSString*)userDefaultsKey
{
	return [NSString stringWithFormat:@"%@_rake_tasks", self.app.name];
}

#pragma mark -
#pragma mark Teardown

- (void)dealloc
{
	RELEASE_SAFELY(searchResults);
	RELEASE_SAFELY(rakeTasks);
	RELEASE_SAFELY(searchDisplayController);
	[super dealloc];
}
@end