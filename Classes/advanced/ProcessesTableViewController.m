//
//  ProcessesTableViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 2/20/11.
//  Copyright 2011 Structlab LLC. All rights reserved.
//

#import "ProcessesTableViewController.h"

@implementation ProcessesTableViewController

@synthesize processesRequest;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style
{
	if (self = [super initWithStyle:style])
	{
		self.title = @"Processes";
	}
	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self showLoadingUI];
	
	[self.heroku processes:self.app.name];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	self.processesRequest.delegate = nil;
	[self.processesRequest cancel];
}

#pragma mark -
#pragma mark Heroku

- (void)herokuReceivedPSOutput:(id)response
{
	[self hideLoadingUI];
		
	if ([response isKindOfClass:[NSArray class]])
	{
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		
		for (NSDictionary *item in response)
		{
			NSString *key = [item objectForKey:@"type"];
			NSMutableArray *list = [dict objectForKey:key];
			
			if (nil == list)
			{
				list = [NSMutableArray array];
				[dict setObject:list forKey:key];
			}
			
			[list addObject:item];
		}
		
		for (NSString *k in [[dict allKeys] sortedArrayUsingSelector:@selector(compare:)])
		{
			NSArray *items = [dict objectForKey:k];
			
			HKTableSection *section = [HKTableSection sectionWithTitle:k];
			
			for (NSDictionary *rowDict in items)
			{
				int elapsed = [[rowDict objectForKey:@"elapsed"] intValue];
				
				NSUInteger h = elapsed / 3600;
				NSUInteger m = (elapsed / 60) % 60;
				NSUInteger s = elapsed % 60;
				
				NSString *formattedTime = [NSString stringWithFormat:@"%u:%02u:%02u", h, m, s];
				
				NSString *stateString = [NSString stringWithFormat:@"%@ for %@", [rowDict objectForKey:@"state"], formattedTime];
				
				HKTableRow *row = [HKTableRow rowWithTitle:[rowDict objectForKey:@"process"] value:stateString target:nil action:nil];
				row.style = UITableViewCellStyleValue1;
				[section.rows addObject:row];
			}
			
			[self.appDetails addObject:section];
		}
		
		[self.tableView reloadData];
	}
	else if (response && ![[NSNull null] isEqual:response])
	{
		[self showError:[response description]];
	}
	else
	{
		[self showError:@"Unable to retrieve process information."];
	}
}

- (void)requestDidFail:(ASIHTTPRequest*)request
{
	NSString *message = [NSString stringWithFormat:@"HTTP status code %d: %@  - %@", request.responseStatusCode, [request responseString], [[request error] localizedDescription]];
	[self showError:message];
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



@end
