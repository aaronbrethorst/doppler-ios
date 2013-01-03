//
//  ConsoleViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 8/6/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "ConsoleViewController.h"
#import "UIScreen+AppleAreAssholes.h"
#import "ASIHTTPRequest.h"
#import "App.h"

@implementation ConsoleViewController

@synthesize app, console, consoleID, parent;

- (id)init
{
	if (self = [super init])
	{
		history = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
		
	self.consoleID = NULL;
		
	self.title = [NSString stringWithFormat:@"Console - %@", self.app.name];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
		
	console = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)]; //prev. -31 on height.
	console.text = @">> ";
	console.editable = NO;
	console.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	console.backgroundColor = [UIColor blackColor];
	console.autocapitalizationType = UITextAutocapitalizationTypeNone;
	console.autocorrectionType = UITextAutocorrectionTypeNo;
	console.font = [UIFont fontWithName:@"Courier" size:[UIFont systemFontSize]];
	console.textColor = [UIColor whiteColor];
	
	[self.view addSubview:console];
	
	if (IS_IPAD())
	{
		commandField = [[UITextField alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 31, self.view.frame.size.width, 31)];
		commandField.font = [UIFont fontWithName:@"Courier" size:[UIFont systemFontSize]];
	}
	else
	{
		commandField = [[UITextField alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 20, self.view.frame.size.width, 20)];
		commandField.font = [UIFont fontWithName:@"Courier" size:[UIFont smallSystemFontSize]];
	}
	
	commandField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	commandField.borderStyle = UITextBorderStyleBezel;
	commandField.backgroundColor = [UIColor whiteColor];
	commandField.delegate = self;
	commandField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	commandField.autocorrectionType = UITextAutocorrectionTypeNo;
	
	UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
	rightButton.frame = CGRectMake(0, 0, 30, 20);
	[rightButton setImage:[UIImage imageNamed:@"list_small.png"] forState:UIControlStateNormal];
	[rightButton addTarget:self action:@selector(showHistory:) forControlEvents:UIControlEventTouchUpInside];
	commandField.rightView = rightButton;
	commandField.rightViewMode = UITextFieldViewModeAlways;

	[self.view addSubview:commandField];
}

- (IBAction)showHistory:(id)sender
{
	ConsoleHistoryTableViewController *hist = [[ConsoleHistoryTableViewController alloc] initWithStyle:UITableViewStylePlain];
	hist.history = history;
	hist.delegate = self;
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:hist];
	
	if (IS_IPAD())
	{
		if (nil == historyPopover)
		{
			historyPopover = [[UIPopoverController alloc] initWithContentViewController:hist];
			historyPopover.popoverContentSize = CGSizeMake(320, 480);
		}
		
		historyPopover.contentViewController = nav;
		[historyPopover presentPopoverFromRect:commandField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
	else
	{
		[self presentModalViewController:nav animated:YES];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"")];
	console.text = [console.text stringByAppendingFormat:@"%@\n",commandField.text];
	[self.heroku consoleCommand:commandField.text forApp:self.app.name withConsoleID:self.consoleID];
	return NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
		
	if (self.consoleID)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteConsoleSession" object:[NSDictionary dictionaryWithObjectsAndKeys:self.consoleID, @"ConsoleID", self.app.name, @"AppName", nil]];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self showLoadingUI];
	[self.heroku consoleTTYForApp:self.app.name];
}

#pragma mark -
#pragma mark Notifications

- (void)keyboardWillShow:(NSNotification *)notification 
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
	
	CGRect keyboardRect = [UIScreen convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] toView:self.view];
	
	CGRect frame = self.console.frame;
	frame.size.height -= keyboardRect.size.height;
		
	if (IS_IPAD())
	{
		frame.size.height += 49; //account for tab bar at bottom
		
		commandField.frame = CGRectMake(0, self.view.frame.size.height - keyboardRect.size.height - 31 + 49, self.view.frame.size.width, 31);
	}
	else
	{
		commandField.frame = CGRectMake(0, self.view.frame.size.height - keyboardRect.size.height - 20, self.view.frame.size.width, 20);
	}
	
	self.console.frame = frame;

	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{	
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
	
	CGRect keyboardRect = [UIScreen convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] toView:self.view];
	
	CGRect frame = self.console.frame;
	frame.size.height += keyboardRect.size.height;
	if (IS_IPAD()) //what the holy fuck... why does this matter?
	{
		frame.size.height -= 49;
	}
	self.console.frame = frame;
	
	commandField.frame = CGRectMake(0, self.view.frame.size.height - 31, self.view.frame.size.width, 31);
	
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark HistoryDelegate

- (void)didSelectHistoryItem:(NSString*)historyText
{
	if (IS_IPAD())
	{
		[historyPopover dismissPopoverAnimated:YES];
	}
	commandField.text = historyText;
}

#pragma mark -
#pragma mark Heroku Delegate

- (void)herokuConsoleTTYFinished:(NSString*)response
{
	self.consoleID = response;
	[self hideLoadingUI];
	[commandField becomeFirstResponder];
}

- (void)herokuConsoleTTYError:(ASIHTTPRequest*)request
{
	[self hideLoadingUI];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[[request error] localizedDescription] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try Again",nil];
	[alert show];
}

- (void)herokuCommandFinished:(NSString*)response
{
	console.text = [console.text stringByAppendingFormat:@"%@\n>> ",response];
	
	[console flashScrollIndicators];
	
	[history insertObject:commandField.text atIndex:0];
	
	commandField.text = @"";
	commandField.enabled = YES;
	
	[commandField becomeFirstResponder];
	
	[self hideLoadingUI];
}

- (void)herokuCommandError:(ASIHTTPRequest*)request
{
	console.text = [console.text stringByAppendingFormat:@"Error: %@ %@\n>> ", request.responseStatusMessage, [request responseString]];
	[console flashScrollIndicators];
	commandField.enabled = YES;
	[self hideLoadingUI];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (0 == buttonIndex)
	{
		//Cancel!
	}
	else
	{
		[self showLoadingUI];
		[self.heroku consoleTTYForApp:self.app.name];
	}
}

#pragma mark -
#pragma mark Dealloc

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.console = NULL;
	self.consoleID = NULL;
	[super viewDidUnload];
}


@end