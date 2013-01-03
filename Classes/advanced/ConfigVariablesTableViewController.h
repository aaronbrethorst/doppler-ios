//
//  ConfigVariablesTableViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 8/9/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDetailsTableViewController.h"
#import "ConfigVariableDelegate.h"

@interface ConfigVariablesTableViewController : AppDetailsTableViewController <ConfigVariableDelegate>
{
}
- (IBAction)add:(id)sender;
@end
