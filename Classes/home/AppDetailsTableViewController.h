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
@property(nonatomic,strong) UIViewController *parent;
@property(nonatomic,strong) App *app;
@property(nonatomic,strong) NSMutableArray *appDetails;
@end
