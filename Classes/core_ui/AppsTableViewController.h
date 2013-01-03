//
//  AppsTableViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 7/22/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKTableViewController.h"

@class HKTabBarController;

@interface AppsTableViewController : HKTableViewController
{
	NSArray *apps;
	HKTabBarController *detailViewController;
}
@property(nonatomic,strong) HKTabBarController *detailViewController;
@property(nonatomic,strong) NSArray *apps;
@end
