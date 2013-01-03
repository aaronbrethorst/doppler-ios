//
//  HeaderView.m
//  heroku
//
//  Created by Aaron Brethorst on 7/25/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "HeaderView.h"
#import "UIView+TKCategory.h"
#import "GradientButton.h"

@implementation HeaderView

@synthesize textField;

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, frame.size.width - 20, 30)];
		textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		textField.borderStyle = UITextBorderStyleBezel;
		textField.backgroundColor = [UIColor whiteColor];
		[self addSubview:textField];
		
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}
- (void)drawRect:(CGRect)rect
{
	CGFloat colors[] =
	{
		200 / 255.0, 207.0 / 255.0, 212.0 / 255.0, 1.00,
		169 / 255.0,  178.0 / 255.0, 185 / 255.0, 1.00
	};

	[UIView drawLinearGradientInRect:CGRectMake(0, 0, rect.size.width, 64) colors:colors];

	CGFloat colors2[] =
	{
		152/255.0, 156/255.0, 161/255.0, 0.6,
		152/255.0, 156/255.0, 161/255.0, 0.1
	};
	
	[UIView drawLinearGradientInRect:CGRectMake(0, 65, rect.size.width, 5) colors:colors2];

	CGFloat line[]={94 / 255.0,  103 / 255.0, 109 / 255.0, 1.00};
	[UIView drawLineInRect:CGRectMake(0, 64.5, 320, 0) colors:line];
}

- (void)dealloc
{
	RELEASE_SAFELY(textField);
	[super dealloc];
}

@end
