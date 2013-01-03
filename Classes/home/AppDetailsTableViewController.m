//
//  AppDetailsTableViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 7/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "AppDetailsTableViewController.h"
#import "App.h"
#import "TouchXML.h"
#import "NSString+Additions.h"

@interface AppDetailsTableViewController ()
- (UITableViewCell*)buildCellWithStyle:(UITableViewCellStyle)style identifier:(NSString*)identifier tableView:(UITableView*)tableView;
@end

@implementation AppDetailsTableViewController

@synthesize app, appDetails, parent;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style])
	{
		self.appDetails = [NSMutableArray array];
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)setApp:(App *)a
{
	[a retain];
	[app release];
	app = a;
	
	if (app)
	{
		self.title = app.name;		
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.appDetails count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[self.appDetails objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	HKTableSection *tsec = [self.appDetails objectAtIndex:section]; 
	return tsec.title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	HKTableSection *tsec = [self.appDetails objectAtIndex:section]; 
	return tsec.footer;
}

- (UITableViewCell*)buildCellWithStyle:(UITableViewCellStyle)style identifier:(NSString*)identifier tableView:(UITableView*)tableView
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (nil == cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier] autorelease];
	}
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
	HKTableRow *row = [[self.appDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	UITableViewCell *cell = nil;
	
	switch (row.style)
	{
		case UITableViewCellStyleDefault:
		{
			static NSString *DefaultCellIdentifier = @"DefaultCellIdentifier";			
			cell = [self buildCellWithStyle:row.style identifier:DefaultCellIdentifier tableView:tableView];
			break;
		}
		case UITableViewCellStyleValue1:
		{
			static NSString *Value1CellIdentifier = @"Value1CellIdentifier";			
			cell = [self buildCellWithStyle:row.style identifier:Value1CellIdentifier tableView:tableView];
			break;
		}
		case UITableViewCellStyleValue2:
		{
			static NSString *Value2CellIdentifier = @"Value2CellIdentifier";			
			cell = [self buildCellWithStyle:row.style identifier:Value2CellIdentifier tableView:tableView];
			break;
		}
		case UITableViewCellStyleSubtitle:
		{
			static NSString *SubtitleCellIdentifier = @"SubtitleCellIdentifier";			
			cell = [self buildCellWithStyle:row.style identifier:SubtitleCellIdentifier tableView:tableView];
			break;
		}
		default:
		{
			break;
		}
	}
		
	cell.textLabel.text = row.title;
	cell.detailTextLabel.text = row.value;
	cell.detailTextLabel.minimumFontSize = 10.0f;
	cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	cell.accessoryType = row.accessoryType;
	
	if (row.image)
	{
		cell.imageView.image = row.image;
	}
	
	if (row.target && row.action)
	{
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	else
	{
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	HKTableRow *row = [[self.appDetails objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	if (row.target && row.action)
	{
		[row.target performSelector:row.action withObject:row];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
	//
}


- (void)dealloc
{
	self.parent = NULL;
	self.app = NULL;
	self.appDetails = NULL;
	[super dealloc];
}

@end