//
//  ConfigVariablesTableViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 8/9/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "ConfigVariablesTableViewController.h"
#import "ConfigVariableEditorViewController.h"
#import "AddConfigVariableTableViewController.h"

@interface ConfigVariablesTableViewController ()
//
@end

@implementation ConfigVariablesTableViewController

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
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = NSLocalizedString(@"Config Variables",@"");
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
	[self reload];
}

#pragma mark -
#pragma mark ConfigVariableDelegate

- (void)reload
{
	[self showLoadingUI];
	[self.heroku configVarsForApp:self.app.name];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)add:(id)sender
{
	UINavigationController *add = [AddConfigVariableTableViewController navigableControllerWithApp:self.app delegate:self];
	[self presentModalViewController:add animated:YES];
}

#pragma mark -
#pragma mark Heroku

- (void)herokuConfigVarsDidFinish:(id)response
{
	NSDictionary *dict = (NSDictionary*)response;
	
	[self.appDetails removeAllObjects];
	
	HKTableSection *section = [HKTableSection sectionWithTitle:@"Config Variables"];
	
	for (NSString *k in dict.allKeys)
	{
		NSString *v = [dict objectForKey:k];
		[section.rows addObject:[HKTableRow rowWithTitle:k
												   value:v
												  target:self
												  action:@selector(showConfigVariable:)
												   style:UITableViewCellStyleSubtitle]];
		
	}
	
	[self.appDetails addObject:section];
	
	if (IS_IPAD())
	{
		HKTableSection *addSection = [HKTableSection sectionWithTitle:nil];
		[addSection.rows addObject:[HKTableRow rowWithTitle:@"Add Config Variable" value:nil target:self action:@selector(add:)]];
		[self.appDetails addObject:addSection];
	}
	
	
	[self hideLoadingUI];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	HKTableRow *row = [[[self.appDetails objectAtIndex:indexPath.section] rows] objectAtIndex:indexPath.row];
	UINavigationController *editor = [ConfigVariableEditorViewController navigableControllerWithApp:self.app key:row.title value:row.value delegate:self];
	
	[self presentModalViewController:editor animated:YES];
}

@end

