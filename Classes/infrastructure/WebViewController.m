//
//  WebViewController.m
//  Heroku
//
//  Created by Aaron Brethorst on 5/18/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
- (void)trySettingTitle;
@end

@implementation WebViewController

@synthesize text, URL, hideToolbar, loadTitleFromDocument;
@synthesize webView, webToolbar;

- (id)init
{
	NSString *xibName = (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() ? @"WebViewController-iPad" : @"WebViewController");
	if (self = [super initWithNibName:xibName bundle:nil])
	{
		self.URL = NULL;
		self.text = NULL;
		self.hideToolbar = NO;
		self.title = @"Loading...";
		self.loadTitleFromDocument = NO;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	webView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];

	if (self.text)
	{
		[webView loadHTMLString:self.text baseURL:nil];
	}
	else if (self.URL)
	{
		[webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
	}
	
	if (self.hideToolbar)
	{
		CGRect webRect = self.webView.frame;
		webRect.size.height += self.webToolbar.frame.size.height;
		self.webView.frame = webRect;
		self.webToolbar.hidden = YES;
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.webView stopLoading];
	[self.webView setDelegate:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	[webView stopLoading];
	self.webView = NULL;
	self.webToolbar = NULL;
}

- (void)dealloc
{
	self.URL = NULL;
	self.text = NULL;
	
    [super dealloc];
}

- (void)trySettingTitle
{
	if (self.loadTitleFromDocument)
	{
		NSString *docTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
		if (docTitle && ![docTitle isEqual:@""])
		{
			self.title = docTitle;
		}
		else
		{
			self.title = NSLocalizedString(@"Loading...",@"");
		}
	}
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	[self trySettingTitle];
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)wv
{
	[self trySettingTitle];
}

- (void)webViewDidFinishLoad:(UIWebView *)wv
{
	[self trySettingTitle];
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error
{
	//[self showError:[error localizedDescription]];
}

@end