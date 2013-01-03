//
//  HKTableViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 7/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "HKTableViewController.h"
#import "LoginViewController.h"

@interface HKTableViewController ()
- (void)composeEmailWithSubject:(NSString*)subject toRecipients:(NSArray*)recipients body:(NSString*)body;
@end


@implementation HKTableViewController

@dynamic heroku;

- (void)viewDidLoad
{
	[super viewDidLoad];
	heroku = [[Heroku alloc] init];
	heroku.username = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_account_used"];
	heroku.apiKey = [[HerokuCredentials sharedHerokuCredentials] passwordForUsername:heroku.username];
    [[HerokuAPIClient sharedClient] setAuthorizationHeaderWithUsername:heroku.username password:heroku.apiKey];
	heroku.delegate = self;
}

- (Heroku*)heroku
{
	return heroku;
}

- (BOOL)iPad
{
	return IS_IPAD();
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)presentLoginViewController
{
	[self presentModalViewController:[LoginViewController navigableLoginViewControllerWithDelegate:self] animated:YES];
}

- (void)showError:(NSString*)message
{
	[self showMessage:message withTitle:@"Error"];
}

- (void)showMessage:(NSString*)message withTitle:(NSString*)title
{
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[alert show];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate
		 
- (void)composeEmailWithSubject:(NSString*)subject toRecipients:(NSArray*)recipients body:(NSString*)body
{
	UIViewController *targetVC = ([self respondsToSelector:@selector(parent)] ? [self performSelector:@selector(parent)] : self);
	
	if ([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController *vc = [[[MFMailComposeViewController alloc] init] autorelease];
		vc.mailComposeDelegate = self;
		[vc setSubject:subject];
		[vc setToRecipients:recipients];
		
		if (body)
		{
			[vc setMessageBody:body isHTML:NO];
		}
		
		[targetVC presentModalViewController:vc animated:YES];
	}
	else
	{
		[self showError:@"Mail not configured. Please configure a mail account and try again."];
	}
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	UIViewController *targetVC = ([self respondsToSelector:@selector(parent)] ? [self performSelector:@selector(parent)] : self);
	
	switch (result)
	{
		case MFMailComposeResultSaved:
		{
			[targetVC dismissModalViewControllerAnimated:YES];
			[self showMessage:@"Your mail draft has been saved." withTitle:@"Draft Saved"];
			break;
		}
		case MFMailComposeResultFailed:
		{
			[self showError:@"Message failed to send"];
			break;
		}
		case MFMailComposeResultCancelled:
		case MFMailComposeResultSent:
		default:
		{
			[targetVC dismissModalViewControllerAnimated:YES];
			break;
		}
	}
}

#pragma mark -
#pragma mark HerokuDelegate

- (void)herokuError:(NSString*)errorMessage
{
    [self hideLoadingUI];
	[self showError:errorMessage];
}

- (void)herokuAuthenticationNeeded
{
	[self presentLoginViewController];
}

- (void)loadData
{
	[self showLoadingUI];
}

- (void)dealloc
{
	heroku.delegate = NULL;
	RELEASE_SAFELY(heroku);
    [super dealloc];
}

- (void)deselectTableSelection
{
	if ([self.tableView indexPathForSelectedRow])
	{
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	}
}

#pragma mark -
#pragma mark LoginViewControllerDelegate

- (void)reloadCredentialsForUsername:(NSString*)username
{
	heroku.apiKey = [[HerokuCredentials sharedHerokuCredentials] passwordForUsername:username];
    [[HerokuAPIClient sharedClient] setAuthorizationHeaderWithUsername:heroku.username password:heroku.apiKey];
	[self loadData];
}

@end

