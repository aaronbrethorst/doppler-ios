//
//  HKTableViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 7/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Heroku.h"
#import "LoginViewControllerDelegate.h"

@interface HKTableViewController : UITableViewController <MFMailComposeViewControllerDelegate, LoginViewControllerDelegate, HerokuDelegate>
{
	Heroku *heroku;
}
@property(weak, nonatomic,readonly) Heroku *heroku;

- (void)showError:(NSString*)message;
- (void)showMessage:(NSString*)message withTitle:(NSString*)title;
- (void)loadData;
- (void)presentLoginViewController;
- (BOOL)iPad;
- (void)deselectTableSelection;
- (void)composeEmailWithSubject:(NSString*)subject toRecipients:(NSArray*)recipients body:(NSString*)body;
@end
