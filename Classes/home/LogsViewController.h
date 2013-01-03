//
//  LogsViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 7/24/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"

@class App;

@interface LogsViewController : WebViewController
{
	SEL herokuSelector;
	App *app;
}
@property(nonatomic,retain) App *app;
@property(nonatomic,assign) SEL herokuSelector;
- (IBAction)loadData:(id)sender;
@end
