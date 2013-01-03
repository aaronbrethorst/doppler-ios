//
//  StructlabTextFieldCell.m
//  Heroku
//
//  Created by Aaron Brethorst on 5/24/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "StructlabNamedTextFieldCell.h"

@implementation StructlabNamedTextFieldCell

@synthesize control;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]))
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		self.textLabel.adjustsFontSizeToFitWidth = NO;
		self.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
		self.detailTextLabel.text = @"IGNORE ME; I'm required";
		self.clipsToBounds = YES;
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
	CGRect textRect = self.detailTextLabel.frame;
	textRect.size.height = [@"MjyW" sizeWithFont:self.detailTextLabel.font].height;
	textRect.size.width = self.bounds.size.width - 110;
	
	self.control.frame = textRect;
	self.detailTextLabel.hidden = YES;
}

- (void)dealloc
{
	RELEASE_SAFELY(control);
	[super dealloc];
}

@end