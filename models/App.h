//
//  App.h
//  heroku
//
//  Created by Aaron Brethorst on 7/22/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchXML.h"

/*
 
 <!-- From /apps -->
 <app>
 <created-at type="datetime">2010-01-08T16:10:07-08:00</created-at>
 <dynos type="integer">1</dynos>
 <id type="integer">112374</id>
 <name>tippr-staging</name>
 <repo-size type="integer">430370816</repo-size>
 <slug-size type="integer">42446848</slug-size>
 <stack>bamboo-ree-1.8.7</stack>
 <workers type="integer">0</workers>
 <create-status type="symbol">complete</create-status>
 <repo-migrate-status type="symbol">complete</repo-migrate-status>
 <domain_name>s.tippr.com</domain_name>
 <owner>jordan@kashless.org</owner>
 </app>
 
 
 <!-- From /apps/:id -->
 
 <app>
 <database_size>647168</database_size>
 <database_tables>13</database_tables>
 <hits_last_hour></hits_last_hour>
 <bandwidth_last_hour></bandwidth_last_hour>
 <web_url>http://fivestar.heroku.com/</web_url>
 <git_url>git@heroku.com:fivestar.git</git_url>
 <cron_next_run>Fri Jul 23 15:12:47 -0700 2010</cron_next_run>
 <cron_finished_at>Thu Jul 22 15:13:00 -0700 2010</cron_finished_at>
 </app>
*/

@interface App : NSObject
{
	NSDate *createdAt;
	int dynos;
	int appID;
	NSString *name;
	int repoSize;
	int slugSize;
	NSString *stack;
	int workers;
	NSString *createStatus;
	NSString *repoMigrateStatus;
	NSString *domainName;
	NSString *owner;
	
	double databaseSize;
	int databaseTables;
	int hitsLastHour;
	double bandwidthLastHour;
	NSString *webURL;
	NSString *gitURL;
	NSDate *cronNextRun;
	NSDate *cronFinishedAt;
}
@property(nonatomic,retain) NSDate *createdAt;
@property(nonatomic,assign) int dynos;
@property(nonatomic,assign) int appID;
@property(nonatomic,retain) NSString *name;
@property(nonatomic,assign) int repoSize;
@property(nonatomic,assign) int slugSize;
@property(nonatomic,retain) NSString *stack;
@property(nonatomic,assign) int workers;
@property(nonatomic,retain) NSString *createStatus;
@property(nonatomic,retain) NSString *repoMigrateStatus;
@property(nonatomic,retain) NSString *domainName;
@property(nonatomic,retain) NSString *owner;

@property(nonatomic,assign) double databaseSize;
@property(nonatomic,assign) int databaseTables;
@property(nonatomic,assign) int hitsLastHour;
@property(nonatomic,assign) double bandwidthLastHour;
@property(nonatomic,retain) NSString *webURL;
@property(nonatomic,retain) NSString *gitURL;
@property(nonatomic,retain) NSDate *cronNextRun;
@property(nonatomic,retain) NSDate *cronFinishedAt;

+ (NSArray*)appsWithXMLString:(NSString*)xmlString;
- (id)initWithCXMLNode:(CXMLNode*)elt;
- (void)populateWithAppXMLNode:(CXMLNode*)elt;
@end
