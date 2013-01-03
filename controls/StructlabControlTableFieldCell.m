//
//  StructlabControlTableFieldCell.m
//  FiveStar
//
//  Created by Aaron Brethorst on 6/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "StructlabControlTableFieldCell.h"

@implementation StructlabControlTableFieldCell

@synthesize control;

+ (CGFloat)rowHeight
{
	return 75.0f;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]))
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.clipsToBounds = YES;
		self.textLabel.adjustsFontSizeToFitWidth = YES;
		self.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
		self.textLabel.text = @"IGNORE ME; I'm required";
	}
	return self;
}

- (void)setControl:(UIView *)c
{
	[c retain];
	[control removeFromSuperview];
	[control release];
	control = c;

	if (control)
	{
		[self.contentView addSubview:control];
		[self setNeedsLayout];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect controlRect = self.control.frame;
	controlRect.size.height = [StructlabControlTableFieldCell rowHeight] - 10;
	controlRect.size.width = self.frame.size.width - 21 - 2;
	controlRect.origin.y = floor((self.frame.size.height - controlRect.size.height) / 2.0f);
	controlRect.origin.x = 2;
		
	self.control.frame = controlRect;
	self.textLabel.hidden = YES;
}

- (void)dealloc
{
	[control release], control = nil;
	[super dealloc];
}

@end
