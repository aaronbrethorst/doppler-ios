//
//  HKTableSection.h
//  heroku
//
//  Created by Aaron Brethorst on 7/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HKTableSection : NSObject
{
	NSString *title;
	NSString *footer;
	NSMutableArray *rows;
}
@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *footer;
@property(nonatomic,retain) NSMutableArray *rows;
+ (HKTableSection*)sectionWithTitle:(NSString*)title;
- (NSInteger)count;
- (id)objectAtIndex:(int)index;
@end

@interface HKTableRow : NSObject
{
	NSString *title;
	NSString *value;
	UIImage *image;
	id metadata;
	id target;
	SEL action;
	UITableViewCellStyle style;
	UITableViewCellAccessoryType accessoryType;
}
@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *value;
@property(nonatomic,retain) UIImage *image;
@property(nonatomic,retain) id metadata;
@property(nonatomic,retain) id target;
@property(nonatomic,assign) SEL action;
@property(nonatomic,assign) UITableViewCellStyle style;
@property(nonatomic,assign) UITableViewCellAccessoryType accessoryType;
+ (HKTableRow*)rowWithTitle:(NSString*)title value:(NSString*)value target:(id)target action:(SEL)action;
+ (HKTableRow*)rowWithTitle:(NSString*)title value:(NSString*)value target:(id)target action:(SEL)action style:(UITableViewCellStyle)style;
- (void)updateAccessoryType;
@end