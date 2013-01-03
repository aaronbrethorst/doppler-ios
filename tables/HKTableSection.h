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
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *footer;
@property(nonatomic,strong) NSMutableArray *rows;
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
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *value;
@property(nonatomic,strong) UIImage *image;
@property(nonatomic,strong) id metadata;
@property(nonatomic,strong) id target;
@property(nonatomic,assign) SEL action;
@property(nonatomic,assign) UITableViewCellStyle style;
@property(nonatomic,assign) UITableViewCellAccessoryType accessoryType;
+ (HKTableRow*)rowWithTitle:(NSString*)title value:(NSString*)value target:(id)target action:(SEL)action;
+ (HKTableRow*)rowWithTitle:(NSString*)title value:(NSString*)value target:(id)target action:(SEL)action style:(UITableViewCellStyle)style;
- (void)updateAccessoryType;
@end