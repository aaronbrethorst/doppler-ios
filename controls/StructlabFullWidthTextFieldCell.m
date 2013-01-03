//
//  StructlabFullWidthTextFieldCell.m
//  FiveStar
//
//  Created by Aaron Brethorst on 6/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "StructlabFullWidthTextFieldCell.h"

@implementation StructlabFullWidthTextFieldCell

@synthesize textField;

+ (CGFloat)rowHeight
{
	return 44.0f;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]))
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		self.textLabel.adjustsFontSizeToFitWidth = YES;
		self.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
		self.textLabel.text = @"IGNORE ME; I'm required";
	}
	return self;
}

- (void)setTextField:(UITextField *)tf
{
	[textField removeFromSuperview];
	textField = tf;
	
	if (textField)
	{
		[self.contentView addSubview:textField];
		[self setNeedsLayout];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect textRect = self.textLabel.frame;
	textRect.size.height = [@"MjyW" sizeWithFont:self.textField.font].height;
	textRect.size.width = self.frame.size.width - 40;
	textRect.origin.y = (self.frame.size.height - textRect.size.height) / 2.0f;
	self.textField.frame = textRect;
	self.textLabel.hidden = YES;
}

- (void)dealloc
{
	textField = nil;
}
@end