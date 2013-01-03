//
//  AddCollaboratorTableViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 8/10/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "AddCollaboratorTableViewController.h"
#import "StructlabNamedTextFieldCell.h"

@implementation AddCollaboratorTableViewController
@synthesize app, delegate;

#pragma mark -
#pragma mark Initialization

+ (UINavigationController*)navigableControllerWithApp:(App*)app delegate:(id<AddCollaboratorTableViewControllerDelegate>)delegate
{
	AddCollaboratorTableViewController *add = [[[AddCollaboratorTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	add.app = app;
	add.delegate = delegate;
	UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:add] autorelease];
	if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
	{
		nav.modalPresentationStyle = UIModalPresentationFormSheet;
	}
	return nav;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	if (self = [super initWithStyle:style])
	{
		self.title = NSLocalizedString(@"Add Collaborator",@"");
	}
	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:self action:@selector(done:)] autorelease];
	
	emailField = [[UITextField alloc] initWithFrame:CGRectZero];
	emailField.delegate = self;
	emailField.autocorrectionType = UITextAutocorrectionTypeNo;
	emailField.returnKeyType = UIReturnKeyNext;
	emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	
	[emailField becomeFirstResponder];
}


#pragma mark -
#pragma mark IBActions

- (IBAction)cancel:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender
{
	[emailField resignFirstResponder];
	[self showLoadingUI];
	[self.heroku addCollaborator:emailField.text toApp:self.app.name];
}

#pragma mark -
#pragma mark Heroku

- (void)herokuAddedCollaborator:(id)response
{
	[self.delegate reload];
	[self dismissModalViewControllerAnimated:YES];
	[self showMessage:[response description] withTitle:@"Message"];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	StructlabNamedTextFieldCell *cell = (StructlabNamedTextFieldCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (nil == cell)
	{
		cell = [[[StructlabNamedTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}

	cell.textLabel.text = @"Email:";
	cell.control = emailField;	
	
	return cell;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	RELEASE_SAFELY(emailField);
}


- (void)dealloc
{
	self.delegate = NULL;
	self.app = NULL;
    [super dealloc];
}


@end

