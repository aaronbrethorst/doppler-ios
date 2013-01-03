//
//  HomeTableViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 7/24/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "HomeTableViewController.h"
#import "HKTableSection.h"
#import "NSString+Additions.h"
#import "LogsViewController.h"

@interface HomeTableViewController ()
- (void)populateTable;
- (void)displayModallyWithNavigationController:(UIViewController*)vc;
@end


@implementation HomeTableViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self populateTable];
}

- (void)populateTable
{
	[self.appDetails removeAllObjects];
	
	HKTableSection *section = [HKTableSection sectionWithTitle:@"Resources"];
	[section.rows addObject:[HKTableRow rowWithTitle:@"Dynos" value:[NSString stringWithFormat:@"%d",self.app.dynos] target:self action:@selector(adjustDynos:)]];
	[section.rows addObject:[HKTableRow rowWithTitle:@"Workers" value:[NSString stringWithFormat:@"%d",self.app.workers] target:self action:@selector(adjustWorkers:)]];
	[self.appDetails addObject:section];
	
	section = [HKTableSection sectionWithTitle:@"Logs"];
	[section.rows addObject:[HKTableRow rowWithTitle:@"App Server Logs" value:nil target:self action:@selector(appLogs:)]];
	[section.rows addObject:[HKTableRow rowWithTitle:@"Cron Logs" value:nil target:self action:@selector(cronLogs:)]];
	[self.appDetails addObject:section];
	
	section = [HKTableSection sectionWithTitle:@"URLs"];
	[section.rows addObject:[HKTableRow rowWithTitle:@"Git URL" value:self.app.gitURL target:nil action:nil]];
	[section.rows addObject:[HKTableRow rowWithTitle:@"Web URL" value:self.app.webURL target:self action:@selector(openWebURL:)]];
	[section.rows addObject:[HKTableRow rowWithTitle:@"Domain" value:self.app.domainName target:self action:@selector(openWebURL:)]];
	[self.appDetails addObject:section];
	
	section = [HKTableSection sectionWithTitle:@"Info"];
	[section.rows addObject:[HKTableRow rowWithTitle:@"Repository" value:[NSString humanFormattedNumber:self.app.repoSize] target:nil action:nil]];
	[section.rows addObject:[HKTableRow rowWithTitle:@"Slug" value:[NSString humanFormattedNumber:self.app.slugSize] target:nil action:nil]];
	
	NSString *dbText = [NSString stringWithFormat:@"%@", [NSString humanFormattedNumber:self.app.databaseSize]];
	[section.rows addObject:[HKTableRow rowWithTitle:@"Database" value:dbText target:nil action:nil]];
    
    [section.rows addObject:[HKTableRow rowWithTitle:@"Stack" value:self.app.stack target:nil action:nil]];
    
	[self.appDetails addObject:section];
}

#pragma mark -
#pragma mark IBActions

- (void)displayModallyWithNavigationController:(UIViewController*)vc
{
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
	if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
	{
		nav.modalPresentationStyle = UIModalPresentationFormSheet;
	}
	
	[self.parent presentModalViewController:nav animated:YES];
}

- (IBAction)openWebURL:(id)sender
{
	HKTableRow *row = (HKTableRow *)sender;
	WebViewController *web = [[WebViewController alloc] init];
	web.loadTitleFromDocument = YES;
	
	if (![row.value hasPrefix:@"http://"])
	{
		web.URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",row.value]];
	}
	else
	{
		web.URL = [NSURL URLWithString:row.value];
	}
	
	[self.parent.navigationController pushViewController:web animated:YES];
}

- (IBAction)adjustDynos:(id)sender
{
	PickerViewController *picker = [[PickerViewController alloc] init];
	picker.title = @"Edit Dynos";
	picker.delegate = self;
	picker.subject = @"Dyno";
	picker.allowsZero = NO;
	picker.initialValue = self.app.dynos;
	[self displayModallyWithNavigationController:picker];	
}

- (IBAction)adjustWorkers:(id)sender
{
	PickerViewController *picker = [[PickerViewController alloc] init];
	picker.title = @"Edit Workers";
	picker.delegate = self;
	picker.subject = @"Worker";
	picker.allowsZero = YES;
	picker.initialValue = self.app.workers;
	[self displayModallyWithNavigationController:picker];
}

- (IBAction)appLogs:(id)sender
{
	LogsViewController *logs = [[LogsViewController alloc] init];
	logs.herokuSelector = @selector(logs:);
	logs.app = self.app;
	logs.title = NSLocalizedString(@"App Logs",@"");
	
	[self.parent.navigationController pushViewController:logs animated:YES];
}

- (IBAction)cronLogs:(id)sender
{
	LogsViewController *logs = [[LogsViewController alloc] init];
	logs.herokuSelector = @selector(cronLogs:);
	logs.app = self.app;
	logs.title = NSLocalizedString(@"Cron Logs",@"");
	[self.parent.navigationController pushViewController:logs animated:YES];
}

#pragma mark -
#pragma mark PickerViewControllerDelegate

- (void)pickerViewDidSelectNumber:(int)number forSubject:(NSString*)subject
{
	[self showLoadingUI];
	
	if ([subject isEqual:@"Worker"])
	{
        [[HerokuAPIClient sharedClient] setBambooApp:self.app.name workers:number success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.heroku info:self.app.name];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self hideLoadingUI];
            [self showError:[error localizedDescription]];
        }];
	}
	else if ([subject isEqual:@"Dyno"])
	{
        [[HerokuAPIClient sharedClient] setBambooApp:self.app.name dynos:number success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.heroku info:self.app.name];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self hideLoadingUI];
            [self showError:[error localizedDescription]];
        }];
	}
}

#pragma mark -
#pragma mark Heroku

- (void)herokuReceivedDynoConfirmation:(NSNumber*)newCount
{
	[self.heroku info:self.app.name];
}

- (void)herokuReceivedWorkerConfirmation:(NSNumber*)newCount
{
	[self.heroku info:self.app.name];
}

- (void)herokuReceivedInfo:(id)obj
{
	CXMLDocument *doc = [[CXMLDocument alloc] initWithXMLString:obj options:0 error:nil];
	[self.app populateWithAppXMLNode:[doc rootElement]];
	[self populateTable];
	[self.tableView reloadData];
	[self hideLoadingUI];
}

- (void)herokuError:(NSString*)errorMessage
{
	[self hideLoadingUI];
	[self showError:errorMessage];
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

