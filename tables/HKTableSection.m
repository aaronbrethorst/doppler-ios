//
//  HKTableSection.m
//  heroku
//
//  Created by Aaron Brethorst on 7/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "HKTableSection.h"

@implementation HKTableSection

@synthesize title, footer, rows;

+ (HKTableSection*)sectionWithTitle:(NSString*)title
{
	HKTableSection *section = [[HKTableSection alloc] init];
	section.title = title;
	return section;
}

- (id)init
{
	if (self = [super init])
	{
		self.rows = [NSMutableArray array];
		self.footer = NULL;
	}
	return self;
}

- (NSInteger)count
{
	return [self.rows count];
}

- (id)objectAtIndex:(int)index
{
	return [self.rows objectAtIndex:index];
}


@end

@implementation HKTableRow

@synthesize title, value, target, action, style, image, metadata, accessoryType;

+ (HKTableRow*)rowWithTitle:(NSString*)title value:(NSString*)value target:(id)target action:(SEL)action style:(UITableViewCellStyle)style
{
	HKTableRow *row = [[HKTableRow alloc] init];
	row.title = title;
	row.value = value;
	row.target = target;
	row.action = action;
	row.style = style;
	
	return row;
}

- (void)setAction:(SEL)sel
{
	action = sel;
	[self updateAccessoryType];
}

- (void)setTarget:(id)t
{
	target = t;
	[self updateAccessoryType];
}

- (void)updateAccessoryType
{
	if (self.action && nil != self.target)
	{
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else
	{
		self.accessoryType = UITableViewCellAccessoryNone;
	}
}

+ (HKTableRow*)rowWithTitle:(NSString*)title value:(NSString*)value target:(id)target action:(SEL)action
{
	return [HKTableRow rowWithTitle:title value:value target:target action:action style:UITableViewCellStyleValue1];
}

- (id)init
{
	if (self = [super init])
	{
		self.title = NULL;
		self.value = NULL;
		self.target = NULL;
		self.metadata = NULL;
		self.action = NULL;
		self.style = 0;
		self.image = NULL;
	}
	return self;
}

- (void)dealloc
{
	self.action = NULL;
	
}
@end