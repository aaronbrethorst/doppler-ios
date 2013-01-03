    //
//  UsersTableViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 7/24/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "UsersTableViewController.h"

@implementation UsersTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self reload];
}

#pragma mark -
#pragma mark Heroku

- (void)herokuReceivedCollaborators:(NSArray*)collaborators
{
	[self.appDetails removeAllObjects];
	
	HKTableSection* section = [HKTableSection sectionWithTitle:@"Users"];
	[section.rows addObject:[HKTableRow rowWithTitle:@"Owner" value:self.app.owner target:nil action:nil]];
	[self.appDetails addObject:section];
	
	section = [HKTableSection sectionWithTitle:@"Collaborators"];
	
	for (NSDictionary *c in collaborators)
	{
		HKTableRow *row = [HKTableRow rowWithTitle:[c objectForKey:kCollaboratorEmailKey] value:nil target:self action:@selector(sendEmail:)];
		row.accessoryType = UITableViewCellAccessoryNone;
		row.image = [UIImage imageNamed:@"mail_small.png"];
		[section.rows addObject:row];	
	}
	section.footer = @"Swipe a row to remove the collaborator.";
	[self.appDetails addObject:section];
	
	section = [HKTableSection sectionWithTitle:nil];
	HKTableRow *addRow = [HKTableRow rowWithTitle:@"Add Collaborator" value:nil target:self action:@selector(addCollaborator:)];
	addRow.image = [UIImage imageNamed:@"user_small.png"];
	addRow.accessoryType = UITableViewCellAccessoryNone;
	[section.rows addObject:addRow];	
	[self.appDetails addObject:section];
	
	[self.tableView reloadData];
	[self hideLoadingUI];
}

- (void)herokuRemovedCollaborator:(id)response
{
	[self reload];
	[self hideLoadingUI];
}

#pragma mark -
#pragma mark UITableView

- (IBAction)sendEmail:(id)sender
{
	HKTableRow *row = (HKTableRow*)sender;
	[self composeEmailWithSubject:self.app.name toRecipients:[NSArray arrayWithObject:row.title] body:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return (1 == indexPath.section);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (UITableViewCellEditingStyleDelete == editingStyle && 1 == indexPath.section)
	{
		HKTableRow *row = [[self.appDetails objectAtIndex:1] objectAtIndex:indexPath.row];
		[self showLoadingUI];
		[self.heroku removeCollaborator:row.title fromApp:self.app.name];
	}
}

#pragma mark -
#pragma mark Blah

- (IBAction)addCollaborator:(id)sender
{
	UINavigationController *add = [AddCollaboratorTableViewController navigableControllerWithApp:self.app delegate:self];
	[self.parent presentModalViewController:add animated:YES];
}

- (void)reload
{
	[self showLoadingUI];
	
	[self.heroku collaborators:self.app.name];
}

#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}



@end