//
//  NSDictionary+Additions.m
//  heroku
//
//  Created by Aaron Brethorst on 7/24/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "NSDictionary+Additions.h"

// helper function: get the string form of any object
static NSString *toString(id object)
{
	return [NSString stringWithFormat: @"%@", object];
}

// helper function: get the url encoded string form of any object
static NSString *urlEncode(id object)
{
	NSString *string = toString(object);
	return [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@implementation NSDictionary (Additions)

- (NSString*)urlEncodedString
{
	NSMutableArray *parts = [NSMutableArray array];
	
	for (id key in self)
	{
		id value = [self objectForKey:key];
		NSString *part = [NSString stringWithFormat:@"%@=%@",urlEncode(key),urlEncode(value)];
		[parts addObject:part];
	}
	return [parts componentsJoinedByString:@"&"];
}


@end
