//
//  Heroku.h
//  heroku
//
//  Created by Aaron Brethorst on 7/22/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "App.h"
#import "HerokuCredentials.h"

#define kCollaboratorAccessKey @"access"
#define kCollaboratorEmailKey @"email"

@class Heroku, ASIHTTPRequest;

@protocol HerokuDelegate<NSObject>
@optional
- (void)herokuReceivedList:(NSArray*)list;
- (void)herokuReceivedInfo:(id)obj;

- (void)herokuReceivedInstalledAddons:(id)obj;
- (void)herokuReceivedAddons:(id)obj;

- (void)herokuReceivedLogs:(NSString*)logs;
- (void)herokuReceivedCronLogs:(NSString*)logs;
- (void)herokuReceivedPSOutput:(NSString*)output;
- (void)herokuReceivedDynoConfirmation:(id)response;
- (void)herokuReceivedWorkerConfirmation:(id)response;
- (void)herokuReceivedCollaborators:(NSArray*)collaborators;
- (void)herokuAuthenticationNeeded;
- (void)herokuMaintenanceModeChanged:(id)obj;
- (void)herokuRestarted:(id)obj;
- (void)herokuRunServiceFinished:(id)response;

- (void)herokuConsoleTTYFinished:(NSString*)response;
- (void)herokuConsoleTTYError:(ASIHTTPRequest*)request;
- (void)herokuCommandFinished:(NSString*)response;
- (void)herokuCommandError:(ASIHTTPRequest*)request;

- (void)herokuConfigVarsDidFinish:(id)response;
- (void)herokuAddedConfigVariable:(id)response;
- (void)herokuRemovedConfigVariable:(id)response;
- (void)herokuAddedCollaborator:(id)response;
- (void)herokuRemovedCollaborator:(id)response;
- (void)herokuError:(NSString*)errorMessage;
@end

@interface Heroku : NSObject
{
	NSString *username;
	NSString *apiKey;
	NSString *host;
	id<HerokuDelegate> delegate;
	ASIHTTPRequest *currentRequest;
}
@property(nonatomic,retain) ASIHTTPRequest* currentRequest;
@property(nonatomic,retain) NSString *username;
@property(nonatomic,retain) NSString *apiKey;
@property(nonatomic,readonly) NSString *host;
@property(nonatomic,assign) id<HerokuDelegate> delegate;
- (void)list;
- (void)info:(NSString*)appName;
- (void)addons;
- (void)installedAddons:(NSString*)appName;
- (void)logs:(NSString*)appName;
- (void)cronLogs:(NSString*)appName;
- (void)setDynos:(int)number forApp:(NSString*)appName;
- (void)setWorkers:(int)number forApp:(NSString*)appName;
- (void)collaborators:(NSString*)appName;
- (void)changeMaintenanceMode:(BOOL)yn forApp:(NSString*)appName;
- (void)restart:(NSString*)appName;
- (void)runService:(NSString*)command forApp:(NSString*)appName;
- (void)processes:(NSString*)appName;
- (void)executeCommand:(NSString*)command forApp:(NSString*)appName;
- (void)consoleTTYForApp:(NSString*)appName;
- (void)consoleCommand:(NSString*)cmd forApp:(NSString*)appName withConsoleID:(NSString*)consoleID;
- (void)deleteConsole:(NSString*)consoleID forApp:(NSString*)appName;
- (void)configVarsForApp:(NSString*)appName;
- (void)addConfigVariableWithKey:(NSString*)key value:(NSString*)value forApp:(NSString*)app;
- (void)removeConfigVariable:(NSString*)key forApp:(NSString*)app;
- (void)addCollaborator:(NSString*)email toApp:(NSString*)app;
- (void)removeCollaborator:(NSString*)email fromApp:(NSString*)app;
@end