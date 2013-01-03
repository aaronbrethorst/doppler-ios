//
//  AppDetailsTableViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 7/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKTableViewController.h"
#import "HKTableSection.h"

@class App;

@interface AppDetailsTableViewController : HKTableViewController
{
	App *app;
	NSMutableArray *appDetails;
	UIViewController *parent;
}
@property(nonatomic,retain) UIViewController *parent;
@property(nonatomic,retain) App *app;
@property(nonatomic,retain) NSMutableArray *appDetails;
@end
