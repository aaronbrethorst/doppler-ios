//
//  RunServiceViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 7/25/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKViewController.h"
#import "HeaderView.h"

@class App;

@interface RunServiceViewController : HKViewController
{
	NSString *serviceCommand;
	App *app;
	UIWebView *webView;
	HeaderView *header;
	BOOL showHeader;
}
@property(nonatomic,retain) App *app;
@property(nonatomic,retain) NSString *serviceCommand;
@property(nonatomic,assign) BOOL showHeader;
- (IBAction)run:(id)sender;
@end