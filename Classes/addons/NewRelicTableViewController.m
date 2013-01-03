//
//  NewRelicTableViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 8/24/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "NewRelicTableViewController.h"
#import "CXMLDocument.h"

@interface NewRelicTableViewController ()
- (void)loadRPMData;
- (void)requestDidFinish:(ASIHTTPRequest*)request;
- (void)requestDidFail:(ASIHTTPRequest*)request;
@end

@implementation NewRelicTableViewController
@synthesize licenseKey, rpmRequest;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style
{
	if (self = [super initWithStyle:style])
	{
		self.title = @"New Relic RPM";
	}
	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self showLoadingUI];
	[self.heroku configVarsForApp:self.app.name];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	self.rpmRequest.delegate = nil;
	[self.rpmRequest cancel];
}

#pragma mark -
#pragma mark Heroku

- (void)herokuConfigVarsDidFinish:(id)response
{
	self.licenseKey = [response objectForKey:@"NEW_RELIC_LICENSE_KEY"];
	
	if (self.licenseKey)
	{
		[self loadRPMData];
	}
	else
	{
		[self showError:@"Unable to retrieve New Relic License Key."];
		[self hideLoadingUI];
	}
}

//curl -is -H "X-LICENSE-KEY:0f7093c6cbafc61c229eab67bdcba271ba5f1122" "http://rpm.newrelic.com/accounts.xml?include=application_health"
- (void)loadRPMData
{
	NSURL *URL = [NSURL URLWithString:@"http://rpm.newrelic.com/accounts.xml?include=application_health"];
	self.rpmRequest = [[[ASIHTTPRequest alloc] initWithURL:URL] autorelease];
	[self.rpmRequest addRequestHeader:@"X-LICENSE-KEY" value:self.licenseKey];
	self.rpmRequest.delegate = self;
	self.rpmRequest.didFinishSelector = @selector(requestDidFinish:);
	self.rpmRequest.didFailSelector = @selector(requestDidFail:);
	[self.rpmRequest startAsynchronous];
}

#pragma mark -
#pragma mark ASIHTTPRequest

- (void)requestDidFinish:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		CXMLDocument *doc = [[CXMLDocument alloc] initWithXMLString:[request responseString] options:0 error:nil];
		
		NSArray *elts = [[doc rootElement] nodesForXPath:@"//application" error:nil];
		
		for (CXMLElement *appNode in elts)
		{
			NSString *appName = [[[appNode elementsForName:@"name"] objectAtIndex:0] stringValue];
			HKTableSection *section = [HKTableSection sectionWithTitle:[NSString stringWithFormat:@"%@ Performance Data",appName]];
			section.footer = @"Data from NewRelic RPM represents the last six minutes of application performance.";
			
			NSArray *thresholdValues = [appNode nodesForXPath:@"//threshold_value" error:nil];
			
			for (CXMLElement *tvElt in thresholdValues)
			{
				NSString *title = [[tvElt attributeForName:@"name"] stringValue];
				NSString *value = [[tvElt attributeForName:@"formatted_metric_value"] stringValue];
				[section.rows addObject:[HKTableRow rowWithTitle:title value:value target:nil action:nil]];
			}
			
			[self.appDetails addObject:section];
		}
		
		[doc release];
		[self.tableView reloadData];
		[self hideLoadingUI];
	}
	else
	{
		[self requestDidFail:request];
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


- (void)dealloc
{
	self.licenseKey = NULL;
	[super dealloc];
}


@end

