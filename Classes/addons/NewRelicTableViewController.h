//
//  NewRelicTableViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 8/24/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDetailsTableViewController.h"
#import "ASIHTTPRequest.h"

@interface NewRelicTableViewController : AppDetailsTableViewController
{
	NSString *licenseKey;
	ASIHTTPRequest *rpmRequest;
}
@property(nonatomic,strong) NSString *licenseKey; 
@property(nonatomic,strong) ASIHTTPRequest *rpmRequest;
@end