//
//  ConsoleViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 8/6/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Heroku.h"
#import "HKViewController.h"
#import "ConsoleHistoryTableViewController.h"

@interface ConsoleViewController : HKViewController <UITextFieldDelegate, UIAlertViewDelegate, HerokuDelegate, HistoryDelegate>
{
	App *app;

	UITextView *console;
	NSString *consoleID;
	UIViewController *parent;
	
	UITextField *commandField;
	
	NSMutableArray *history;
	UIPopoverController *historyPopover;
}
@property(nonatomic,retain) NSString *consoleID;
@property(nonatomic,retain) App *app;
@property(nonatomic,retain) UIViewController *parent;
@property(nonatomic,retain) UITextView *console;
- (IBAction)showHistory:(id)sender;
@end
