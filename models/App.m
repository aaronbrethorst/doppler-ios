//
//  App.m
//  heroku
//
//  Created by Aaron Brethorst on 7/22/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "App.h"

@interface App ()
- (void)populateWithNode:(CXMLNode*)node;
- (NSDateFormatter*)cronFormatter;
@end


@implementation App

@synthesize createdAt, dynos, appID, name, repoSize, slugSize, stack, workers, createStatus, repoMigrateStatus, domainName, owner;

@synthesize databaseSize, databaseTables, hitsLastHour, bandwidthLastHour, webURL, gitURL, cronNextRun, cronFinishedAt;

+ (NSArray*)appsWithXMLString:(NSString*)xmlString
{
	NSMutableArray *array = [NSMutableArray array];
	
	CXMLDocument *doc = [[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil];	
	NSArray *kids = [doc nodesForXPath:@"apps/app" error:nil];
	
	for (CXMLElement *elt in kids)
	{
		App *a = [[App alloc] initWithCXMLNode:elt];
		[array addObject:a];
	}
	
	[array sortUsingSelector:@selector(compare:)];
	
	return array;
}

- (id)initWithCXMLNode:(CXMLNode*)elt
{
	if (self = [super init])
	{
		[self populateWithAppXMLNode:elt];
	}
	return self;
}

- (void)populateWithAppXMLNode:(CXMLNode*)elt
{
	for (CXMLNode *e in [elt children])
	{
		[self populateWithNode:e];
	}
}

- (void)populateWithNode:(CXMLNode*)node
{
	NSString *nodeName = [node name];
	NSString *stringValue = [node stringValue];
	
	if ([nodeName isEqual:@"dynos"])
	{
		self.dynos = [stringValue intValue];
	}
	else if ([nodeName isEqual:@"id"])
	{
		self.appID = [stringValue intValue];
	}
	else if ([nodeName isEqual:@"name"])
	{
		self.name = stringValue;
	}
	else if ([nodeName isEqual:@"repo-size"])
	{
		self.repoSize = [stringValue intValue];
	}
	else if ([nodeName isEqual:@"slug-size"])
	{
		self.slugSize = [stringValue intValue];
	}
	else if ([nodeName isEqual:@"stack"])
	{
		self.stack = stringValue;
	}
	else if ([nodeName isEqual:@"workers"])
	{
		self.workers = [stringValue intValue];
	}
	else if ([nodeName isEqual:@"create-status"])
	{
		self.createStatus = stringValue;
	}
	else if ([nodeName isEqual:@"repo-migrate-status"])
	{
		self.repoMigrateStatus = stringValue;
	}
	else if ([nodeName isEqual:@"domain_name"])
	{
		self.domainName = stringValue;
	}
	else if ([nodeName isEqual:@"owner"])
	{
		self.owner = stringValue;
	}
	else if ([nodeName isEqual:@"database_size"])
	{
		self.databaseSize = [stringValue intValue];
	}
	else if ([nodeName isEqual:@"database_tables"])
	{
		self.databaseTables = [stringValue intValue];
	}
	else if ([nodeName isEqual:@"hits_last_hour"])
	{
		self.hitsLastHour = [stringValue intValue];
	}
	else if ([nodeName isEqual:@"bandwidth_last_hour"])
	{
		self.bandwidthLastHour = [stringValue doubleValue];
	}
	else if ([nodeName isEqual:@"web_url"])
	{
		self.webURL = stringValue;
	}
	else if ([nodeName isEqual:@"git_url"])
	{
		self.gitURL = stringValue;
	}
	else if ([nodeName isEqual:@"cron_next_run"])
	{
		self.cronNextRun = [[self cronFormatter] dateFromString:stringValue];
	}
	else if ([nodeName isEqual:@"cron_finished_at"])
	{
		self.cronFinishedAt = [[self cronFormatter] dateFromString:stringValue];
	}
}

- (NSString*)domainName
{
	if (!domainName)
	{
		return [NSString stringWithFormat:@"%@.heroku.com", name];
	}
	else
	{
		return domainName;
	}
}

- (NSComparisonResult)compare:(App*)a
{
	return [self.name compare:a.name];
}

- (void)dealloc
{
	self.databaseSize = -1;
	self.databaseTables = -1;
	self.hitsLastHour = -1;
	self.bandwidthLastHour = -1;
	self.dynos = -1;
	self.appID = -1;
	self.repoSize = -1;
	self.slugSize = -1;
	self.workers = -1;
	
}

- (NSDateFormatter*)cronFormatter
{
	NSDateFormatter *cronFormatter = [[NSDateFormatter alloc] init];
	[cronFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[cronFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];    
	[cronFormatter setDateFormat:@"EEE LLL dd HH:mm:ss ZZZ yyyy"];
	return cronFormatter;
}

@end
