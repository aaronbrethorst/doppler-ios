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
@property(nonatomic,strong) NSURL *URL;
@property(nonatomic,strong) NSString *text;
@property(nonatomic,strong) IBOutlet UIWebView *webView;
@property(nonatomic,strong) IBOutlet UIToolbar *webToolbar;
@end