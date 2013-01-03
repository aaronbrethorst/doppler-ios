//
//  AddCollaboratorTableViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 8/10/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKTableViewController.h"
#import "App.h"

@protocol AddCollaboratorTableViewControllerDelegate<NSObject>
- (void)reload;
@end


@interface AddCollaboratorTableViewController : HKTableViewController <UITextFieldDelegate>
{
	App *app;
	id<AddCollaboratorTableViewControllerDelegate> delegate;
	
	UITextField *emailField;
}
@property(nonatomic,retain) App *app;
@property(nonatomic,assign) id<AddCollaboratorTableViewControllerDelegate> delegate;
+ (UINavigationController*)navigableControllerWithApp:(App*)app delegate:(id<AddCollaboratorTableViewControllerDelegate>)delegate;
@end
