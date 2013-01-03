//
//  ConfigVariableEditorViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 8/9/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "ConfigVariableEditorViewController.h"
#import "StructlabNamedTextFieldCell.h"

@implementation ConfigVariableEditorViewController
@synthesize configVariableKey, configVariableValue, app, delegate;

+ (UINavigationController*)navigableControllerWithApp:(App*)app key:(NSString*)key value:(NSString*)value delegate:(id<ConfigVariableDelegate>)delegate
{
	ConfigVariableEditorViewController *editor = [[[ConfigVariableEditorViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	editor.app = app;
	editor.configVariableKey = key;
	editor.configVariableValue = value;
	editor.delegate = delegate;
	UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:editor] autorelease];
	
	if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
	{
		nav.modalPresentationStyle = UIModalPresentationFormSheet;
	}
	
	return nav;
}

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style
{
	if (self = [super initWithStyle:style])
	{
		self.title = NSLocalizedString(@"Edit", @"");
	}
	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	valueField = [[UITextField alloc] initWithFrame:CGRectZero];
	valueField.delegate = self;
	valueField.autocorrectionType = UITextAutocorrectionTypeNo;
	valueField.keyboardType = UIKeyboardTypeEmailAddress;
	valueField.returnKeyType = UIReturnKeyDone;
	valueField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	valueField.text = self.configVariableValue;
		
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(done:)] autorelease];
	
}

- (IBAction)cancel:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender
{
	[self showLoadingUI];
	
	[self.heroku addConfigVariableWithKey:self.configVariableKey value:valueField.text forApp:self.app.name];
}

#pragma mark -
#pragma mark Heroku

- (void)herokuAddedConfigVariable:(id)response
{
	[self.delegate reload];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)herokuRemovedConfigVariable:(id)response
{
	[self.delegate reload];
	[self dismissModalViewControllerAnimated:YES];
	[self showMessage:@"Config variable deleted." withTitle:@"Deleted"];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (0 == section)
	{
		return self.configVariableKey;
	}
	else
	{
		return nil;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	if (0 == indexPath.section)
	{
		static NSString *EditCellIdentifier = @"EditCell";
		
		StructlabNamedTextFieldCell *cell = (StructlabNamedTextFieldCell*)[tableView dequeueReusableCellWithIdentifier:EditCellIdentifier];
		
		if (nil == cell)
		{
			cell = [[[StructlabNamedTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EditCellIdentifier] autorelease];
		}
		
		cell.textLabel.text = @"Value:";
		cell.control = valueField;
		
		return cell;
	}
	else
	{
		static NSString *CellIdentifier = @"DeleteCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
				
		if (nil == cell)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.textLabel.textAlignment = UITextAlignmentCenter;
		}
		
		cell.textLabel.text = @"Delete Config Variable";
		
		return cell;
	}
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (1 == indexPath.section)
	{
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Are you sure you want to delete this config variable?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil] autorelease];
		[alert show];
	}
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (1 == buttonIndex) //DELETE!
	{
		[self showLoadingUI];
		[self.heroku removeConfigVariable:self.configVariableKey forApp:self.app.name];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
	self.app = NULL;
	self.configVariableKey = NULL;
	self.configVariableValue = NULL;
	
	[super dealloc];
}


@end

