//
//  HKViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 7/24/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Heroku.h"
#import "LoginViewControllerDelegate.h"

@interface HKViewController : UIViewController <MFMailComposeViewControllerDelegate, LoginViewControllerDelegate, HerokuDelegate>
{
	Heroku *heroku;
}
@property(nonatomic,readonly) Heroku * heroku;

- (void)showError:(NSString*)message;
- (void)loadData;
- (void)composeEmailWithSubject:(NSString*)subject toRecipients:(NSArray*)recipients body:(NSString*)body;
@end
