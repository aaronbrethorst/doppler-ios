//
//  AddConfigVariableTableViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 8/9/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "AddConfigVariableTableViewController.h"
#import "App.h"
#import "StructlabNamedTextFieldCell.h"

@implementation AddConfigVariableTableViewController
@synthesize app, key, value, delegate;

+ (UINavigationController*)navigableControllerWithApp:(App*)app delegate:(id<ConfigVariableDelegate>)delegate
{
	AddConfigVariableTableViewController *add = [[[AddConfigVariableTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	add.app = app;
	add.delegate = delegate;
	UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:add] autorelease];
	
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
    if ((self = [super initWithStyle:style]))
	{
		self.title = NSLocalizedString(@"Add",@"");
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	key = [[UITextField alloc] initWithFrame:CGRectZero];
	key.delegate = self;
	key.autocorrectionType = UITextAutocorrectionTypeNo;
	key.returnKeyType = UIReturnKeyNext;
	key.autocapitalizationType = UITextAutocapitalizationTypeNone;
		
	value = [[UITextField alloc] initWithFrame:CGRectZero];
	value.delegate = self;
	value.autocorrectionType = UITextAutocorrectionTypeNo;
	value.autocapitalizationType = UITextAutocapitalizationTypeNone;
	value.returnKeyType = UIReturnKeyDone;
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:self action:@selector(done:)] autorelease];
	
	[key becomeFirstResponder];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)cancel:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender
{
	[self showLoadingUI];
	
	[self.heroku addConfigVariableWithKey:key.text value:value.text forApp:self.app.name];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (key == textField)
	{
		[value becomeFirstResponder];
	}
	else if (value == textField)
	{
		[value resignFirstResponder];
		[self done:value];
	}
	
	return YES;
}

#pragma mark -
#pragma mark Heroku

- (void)herokuAddedConfigVariable:(id)response
{
	[self.delegate reload];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	StructlabNamedTextFieldCell *cell = (StructlabNamedTextFieldCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (nil == cell)
	{
		cell = [[[StructlabNamedTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	if (0 == indexPath.row)
	{
		cell.textLabel.text = @"Key:";
		cell.control = key;	
	}
	else
	{		
		cell.textLabel.text = @"Value:";
		cell.control = value;
	}
		
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

