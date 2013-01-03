//
//  ConsoleHistoryTableViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 8/14/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HistoryDelegate<NSObject>
- (void)didSelectHistoryItem:(NSString*)historyText;
@end


@interface ConsoleHistoryTableViewController : UITableViewController
{
	NSArray *history;
	id<HistoryDelegate> delegate;
}
@property(nonatomic,assign) id<HistoryDelegate> delegate;
@property(nonatomic,retain) NSArray *history;
- (IBAction)close:(id)sender;
@end
