//
//  RakeTableViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 7/25/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDetailsTableViewController.h"

#define kTaskName @"name"
#define kTaskDescription @"task_desc"

@interface RakeTableViewController : AppDetailsTableViewController <UISearchBarDelegate, UISearchDisplayDelegate>
{
	NSMutableArray *rakeTasks;
	NSMutableArray *searchResults;
	UISearchDisplayController *searchDisplayController;
}
@end
