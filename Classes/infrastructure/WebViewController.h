//
//  WebViewController.h
//  Heroku
//
//  Created by Aaron Brethorst on 5/18/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKViewController.h"

@interface WebViewController : HKViewController <UIWebViewDelegate>
{
	UIWebView *webView;
	NSURL *URL;
	NSString *text;
	UIToolbar *webToolbar;
	BOOL hideToolbar;
	BOOL loadTitleFromDocument;
}
@property(nonatomic,assign) BOOL loadTitleFromDocument;
@property(nonatomic,assign) BOOL hideToolbar;
@property(nonatomic,retain) NSURL *URL;
@property(nonatomic,retain) NSString *text;
@property(nonatomic,retain) IBOutlet UIWebView *webView;
@property(nonatomic,retain) IBOutlet UIToolbar *webToolbar;
@end