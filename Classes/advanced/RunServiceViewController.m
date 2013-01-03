//
//  RunServiceViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 7/25/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "RunServiceViewController.h"

@implementation RunServiceViewController

@synthesize serviceCommand, app, showHeader;

- (id)init
{
	if (self = [super init])
	{
		self.showHeader = YES;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	webView = [[UIWebView alloc] initWithFrame:CGRectZero];
	webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[webView loadHTMLString:@"" baseURL:nil];
	[self.view addSubview:webView];
	
	if (self.showHeader)
	{
		header = [[HeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
		header.textField.text = self.serviceCommand;
		[self.view addSubview:header];	
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Run" style:UIBarButtonItemStyleDone target:self action:@selector(run:)];
		webView.frame = CGRectMake(0, 76, self.view.frame.size.width, self.view.bounds.size.height - header.frame.size.height);
	}
	else
	{
		webView.frame = self.view.frame;
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(run:)];
	}
}

- (IBAction)run:(id)sender
{
	[self showLoadingUI];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	if (self.showHeader)
	{
		header.textField.enabled = NO;
		[self.heroku runService:header.textField.text forApp:self.app.name];		
	}
	else
	{
		[self.heroku runService:self.serviceCommand forApp:self.app.name];
	}
}

#pragma mark -
#pragma mark Heroku

- (void)herokuRunServiceFinished:(id)response
{
	NSMutableString *page = [[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pre_webpage" ofType:@"html"]];
	[page replaceOccurrencesOfString:@"${CONTENT}" withString:response options:NSLiteralSearch range:NSMakeRange(0, [page length])];
	[webView loadHTMLString:page baseURL:nil];
	
	self.navigationItem.rightBarButtonItem.enabled = YES;
	if (self.showHeader)
	{
		header.textField.enabled = YES;
	}
	[self hideLoadingUI];
}

@end
