//
//  UsersTableViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 7/24/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDetailsTableViewController.h"
#import "AddCollaboratorTableViewController.h"

@interface UsersTableViewController : AppDetailsTableViewController <AddCollaboratorTableViewControllerDelegate>
{

}
- (IBAction)sendEmail:(id)sender;
- (IBAction)addCollaborator:(id)sender;
@end
