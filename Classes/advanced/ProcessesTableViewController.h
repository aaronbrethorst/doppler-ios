//
//  ProcessesTableViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 2/20/11.
//  Copyright 2011 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDetailsTableViewController.h"
#import "ASIHTTPRequest.h"

@interface ProcessesTableViewController : AppDetailsTableViewController
{
	ASIHTTPRequest *processesRequest;
}
@property(nonatomic,strong) ASIHTTPRequest *processesRequest;
@end
