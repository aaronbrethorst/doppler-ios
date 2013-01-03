//
//  NSString+Additions.m
//  FiveStar
//
//  Created by Aaron Brethorst on 5/30/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)
- (NSString*)reallyURLEscape
{
	NSString* escaped = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
																			(CFStringRef)self,
																			NULL,
																			(CFStringRef)@".!*'();:@&=+$,/?%#[]",
																			kCFStringEncodingUTF8 ));
	return escaped;
}

+ (NSString *)humanFormattedNumber:(int)theSize
{
	float floatSize = theSize;
	if (theSize<1023)
		return([NSString stringWithFormat:@"%i bytes",theSize]);
	floatSize = floatSize / 1024;
	if (floatSize<1023)
		return([NSString stringWithFormat:@"%1.1f KB",floatSize]);
	floatSize = floatSize / 1024;
	if (floatSize<1023)
		return([NSString stringWithFormat:@"%1.1f MB",floatSize]);
	floatSize = floatSize / 1024;
		
	return([NSString stringWithFormat:@"%1.1f GB",floatSize]);
}
@end

@implementation NSMutableString (Additions)
- (void)appendIfNotNil:(NSString*)text
{
	if (text && ![text isEqual:[NSNull null]])
	{
		[self appendString:text];
	}
}
@end