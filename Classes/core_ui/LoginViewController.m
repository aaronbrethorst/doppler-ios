//
//  LoginViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 7/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "LoginViewController.h"
#import "StructlabNamedTextFieldCell.h"
#import "Heroku.h"

@implementation LoginViewController
@synthesize delegate;

#pragma mark -
#pragma mark Initialization

+ (UINavigationController*)navigableLoginViewControllerWithDelegate:(id<LoginViewControllerDelegate>)delegate
{
	LoginViewController *login = [[LoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
	login.delegate = delegate;
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];

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
		self.title = NSLocalizedString(@"Log In to Heroku",@"");
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	usernameField = [[UITextField alloc] initWithFrame:CGRectZero];
	usernameField.delegate = self;
	usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
	usernameField.keyboardType = UIKeyboardTypeEmailAddress;
	usernameField.returnKeyType = UIReturnKeyNext;
	usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	usernameField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_account_used"];

	passwordField = [[UITextField alloc] initWithFrame:CGRectZero];
	passwordField.delegate = self;
	passwordField.secureTextEntry = YES;
	passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
	passwordField.returnKeyType = UIReturnKeyDone;

	passwordSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
	passwordSwitch.on = NO;

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];

	if ([usernameField.text length] == 0)
	{
		[usernameField becomeFirstResponder];
	}
	else
	{
		[passwordField becomeFirstResponder];
	}
}

- (IBAction)cancel:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender
{
	if ([usernameField.text length] > 0 && [passwordField.text length] > 0)
	{
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Logging in...", @"")];
        
        [[HerokuAPIClient sharedClient] loginWithUsername:usernameField.text password:passwordField.text success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[HerokuCredentials sharedHerokuCredentials] addUsername:[responseObject objectForKey:@"email"] password:[responseObject objectForKey:@"api_key"] savePassword:passwordSwitch.on];
            [delegate reloadCredentialsForUsername:usernameField.text];
            [self hideLoadingUI];
            [self dismissModalViewControllerAnimated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self hideLoadingUI];
            [self showError:[error localizedDescription]];
        }];
	}
	else
	{
		[self showError:NSLocalizedString(@"Please fill in your username and password.", @"")];
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (usernameField == textField)
	{
		[passwordField becomeFirstResponder];
	}
	else if (passwordField == textField)
	{
		[self done:passwordField];
	}

	return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (0 == section)
	{
		return 1;
	}
	else
	{
		return 2;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";

	StructlabNamedTextFieldCell *cell = (StructlabNamedTextFieldCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (nil == cell)
	{
		cell = [[StructlabNamedTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	if (0 == indexPath.section)
	{
		cell.textLabel.text = @"Email:";
		cell.control = usernameField;
	}
	else
	{
		if (0 == indexPath.row)
		{
			cell.textLabel.text = @"Password:";
			cell.control = passwordField;
		}
		else
		{
			cell.textLabel.text = @"Remember?";
			cell.control = passwordSwitch;
		}
	}

	return cell;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
}



@end

