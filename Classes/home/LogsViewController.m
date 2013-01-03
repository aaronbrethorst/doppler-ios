    //
//  LogsViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 7/24/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "LogsViewController.h"
#import "Heroku.h"
#import "App.h"

@interface LogsViewController ()
- (void)loadLogs:(NSString*)logs;
@end

@implementation LogsViewController

@synthesize app, herokuSelector;

- (id)init
{
	if (self = [super init])
	{
		self.hideToolbar = YES;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self loadData:nil];

	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadData:)] autorelease];
}

- (IBAction)loadData:(id)sender
{
	self.navigationItem.rightBarButtonItem.enabled = NO;
	[self showLoadingUI];
	[self.heroku performSelector:self.herokuSelector withObject:self.app.name];
}

- (void)dealloc
{
	self.app = NULL;
	self.herokuSelector = NULL;
    [super dealloc];
}

- (void)herokuReceivedLogs:(NSString*)logs
{
	[self loadLogs:logs];
}

- (void)herokuRunServiceFinished:(NSString*)results
{
    [self loadLogs:results];
}

- (void)herokuReceivedCronLogs:(NSString*)logs
{
	[self loadLogs:logs];
}

- (void)herokuReceivedPSOutput:(NSString*)output
{
	[self loadLogs:output];
}

- (void)loadLogs:(NSString*)logs
{
	NSMutableString *string = [[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pre_webpage" ofType:@"html"]];

	if (0 == [logs length] || nil == logs)
	{
		[string replaceOccurrencesOfString:@"${CONTENT}" withString:@"No data found." options:NSLiteralSearch range:NSMakeRange(0, [string length])];
	}
	else
	{
		[string replaceOccurrencesOfString:@"${CONTENT}" withString:logs options:NSLiteralSearch range:NSMakeRange(0, [string length])];
	}
	[self.webView loadHTMLString:string baseURL:nil];
	[self hideLoadingUI];
	self.navigationItem.rightBarButtonItem.enabled = YES;
	[string release];
}
@end
