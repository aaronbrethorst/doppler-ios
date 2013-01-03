//
//  Heroku.m
//  heroku
//
//  Created by Aaron Brethorst on 7/22/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "Heroku.h"
#import "ASIHTTPRequest.h"
#import "NSString+Additions.h"
#import "NSDictionary+Additions.h"
#import "SBJson.h"

@interface Heroku ()
- (void)addHeadersToRequest:(ASIHTTPRequest*)request;
- (void)broadcast:(SEL)selector withObject:(id)object;
- (void)requestDidFail:(ASIHTTPRequest*)request;
- (ASIHTTPRequest*)putRequestForResource:(NSString*)resource withFormData:(NSDictionary*)dict;
- (ASIHTTPRequest*)postRequestForResource:(NSString*)resource withFormDictionary:(NSDictionary*)dict;
- (ASIHTTPRequest*)postRequestForResource:(NSString*)resource withFormData:(NSData*)data;
- (ASIHTTPRequest*)requestForURL:(NSURL*)URL didFinish:(SEL)didFinish didFail:(SEL)didFail contentType:(NSString*)contentType;
- (ASIHTTPRequest*)requestForResource:(NSString *)resource didFinish:(SEL)didFinish didFail:(SEL)didFail contentType:(NSString*)contentType;
- (ASIHTTPRequest*)requestForResource:(NSString *)resource didFinish:(SEL)didFinish didFail:(SEL)didFail;
- (ASIHTTPRequest*)deleteRequestForResource:(NSString*)resource didFinish:(SEL)didFinish didFail:(SEL)didFail;

- (void)readChunkFromURL:(NSURL*)url forAppName:(NSString*)appName withResults:(NSString*)results;
@end


@implementation Heroku

@synthesize username, apiKey, host, delegate, currentRequest;

- (id)init
{
	if (self = [super init])
	{
		host = @"heroku.com";
		delegate = nil;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePassword:) name:@"NukeHerokuPasswords" object:nil];
	}
	return self;
}

- (void)removePassword:(NSNotification*)note
{
	self.apiKey = NULL;
}

#pragma mark -
#pragma mark Delegate

- (void)broadcast:(SEL)selector
{
	if (self.delegate && [self.delegate respondsToSelector:selector])
	{
		[self.delegate performSelector:selector];
	}
}

- (void)broadcast:(SEL)selector withObject:(id)object
{
	if (self.delegate && [self.delegate respondsToSelector:selector])
	{
		[self.delegate performSelector:selector withObject:object];
	}
}

#pragma mark -
#pragma mark ASIHTTPRequest

- (void)addHeadersToRequest:(ASIHTTPRequest*)request
{
	[request addRequestHeader:@"X-heroku-api-version" value:@"2"];
	[request addRequestHeader:@"Accept" value:@"*/*; q=0.5, application/xml"];
	[request addRequestHeader:@"User-Agent" value:@"heroku-gem/2.3.6"];
	[request addRequestHeader:@"X-ruby-version" value:@"1.9.2"];
	[request addRequestHeader:@"X-ruby-platform" value:@"x86_64-darwin11.0.0"];

	request.shouldPresentCredentialsBeforeChallenge = YES;
	[request addBasicAuthenticationHeaderWithUsername:self.username andPassword:self.apiKey];
}

- (ASIHTTPRequest*)deleteRequestForResource:(NSString*)resource didFinish:(SEL)didFinish didFail:(SEL)didFail
{
	NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.heroku.com/%@", resource]];
	ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:URL];
	request.requestMethod = @"DELETE";
	[self addHeadersToRequest:request];
	request.delegate = self;
	request.didFinishSelector = didFinish;
	request.didFailSelector = didFail;

	return request;
}

- (ASIHTTPRequest*)putRequestForResource:(NSString*)resource withFormData:(NSDictionary*)dict
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.heroku.com/%@", resource]];
	ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:URL];
	request.requestMethod = @"PUT";
	[self addHeadersToRequest:request];
	request.delegate = self;
	request.didFailSelector = @selector(requestDidFail:);
	NSData *data = [[dict urlEncodedString] dataUsingEncoding:NSUTF8StringEncoding];
	[request appendPostData:data];

	return request;
}

- (ASIHTTPRequest*)postRequestForResource:(NSString*)resource withFormData:(NSData*)data
{
	NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.heroku.com/%@", resource]];
	ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:URL];
	request.requestMethod = @"POST";
	[self addHeadersToRequest:request];
	request.delegate = self;
	request.didFailSelector = @selector(requestDidFail:);
	[request appendPostData:data];

	return request;

}

- (ASIHTTPRequest*)postRequestForResource:(NSString*)resource withFormDictionary:(NSDictionary*)dict
{
	return [self postRequestForResource:resource withFormData:[[dict urlEncodedString] dataUsingEncoding:NSUTF8StringEncoding]];
}

- (ASIHTTPRequest*)requestForURL:(NSURL*)URL didFinish:(SEL)didFinish didFail:(SEL)didFail contentType:(NSString*)contentType
{
	ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL:URL];
	[self addHeadersToRequest:request];
	if (contentType)
	{
		[request addRequestHeader:@"Content-Type" value:contentType];
        [request addRequestHeader:@"Accept" value:contentType];
	}
	[request setDelegate:self];
	[request setDidFinishSelector:didFinish];
	[request setDidFailSelector:didFail];

	return request;
}

- (ASIHTTPRequest*)requestForResource:(NSString *)resource didFinish:(SEL)didFinish didFail:(SEL)didFail contentType:(NSString*)contentType
{
	NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.heroku.com/%@",resource]];
	return [self requestForURL:URL didFinish:didFinish didFail:didFail contentType:contentType];
}

- (ASIHTTPRequest*)requestForResource:(NSString *)resource didFinish:(SEL)didFinish didFail:(SEL)didFail
{
	return [self requestForResource:resource didFinish:didFinish didFail:didFail contentType:@"application/xml"];
}

- (void)requestDidFail:(ASIHTTPRequest*)request
{
	NSError *underlyingError = [[request.error userInfo] objectForKey:NSUnderlyingErrorKey];

	if (401 == request.responseStatusCode)
	{
		[self broadcast:@selector(herokuAuthenticationNeeded)];
	}
	else if (underlyingError)
	{
		NSMutableArray *errorData = [NSMutableArray array];
		[errorData addObject:[NSString stringWithFormat:@"Failure to retrieve URL %@", [request url]]];
		[errorData addObject:@"Failure of type ASIConnectionFailureErrorType"];
		[errorData addObject:[NSString stringWithFormat:@"Underlying error is %@", underlyingError]];
		[errorData addObject:[NSString stringWithFormat:@"Error domain: %@ (code: %d)", [underlyingError domain], [underlyingError code]]];
		[errorData addObject:[NSString stringWithFormat:@"User info: %@", [underlyingError userInfo]]];
		[errorData addObject:[NSString stringWithFormat:@"Localized Description: %@", [underlyingError localizedDescription]]];
		[errorData addObject:[NSString stringWithFormat:@"Localized Failure Reason: %@", [underlyingError localizedFailureReason]]];
		[errorData addObject:[NSString stringWithFormat:@"Localized Recovery Suggestion: %@", [underlyingError localizedRecoverySuggestion]]];
		[errorData addObject:[NSString stringWithFormat:@"Localized recovery options: %@", [underlyingError localizedRecoveryOptions]]];

		[self broadcast:@selector(herokuError:) withObject:[errorData componentsJoinedByString:@"\n"]];
	}
	else
	{
		NSMutableArray *messages = [NSMutableArray array];

		[messages addObject:[NSString stringWithFormat:@"HTTP Code %d",request.responseStatusCode]];

		if (nil != [request responseString] && [[request responseString] length] > 0)
		{
			NSError *error = nil;
			CXMLDocument *doc = [[CXMLDocument alloc] initWithXMLString:[request responseString] options:0 error:&error];

			if (error)
			{
				[messages addObject:[request responseString]];
			}
			else
			{
				NSArray *nodes = [doc nodesForXPath:@"//error" error:nil];
				for (CXMLNode *node in nodes)
				{
					[messages addObject:[node stringValue]];
				}
			}

			doc = nil;
		}

		if (nil != [[request error] localizedDescription])
		{
			[messages addObject:[[request error] localizedDescription]];
		}


		[self broadcast:@selector(herokuError:) withObject:[messages componentsJoinedByString:@", "]];
	}
}

#pragma mark -
#pragma mark List API

- (void)list
{
	self.currentRequest = [self requestForResource:@"apps"
										 didFinish:@selector(listDidFinish:)
										   didFail:@selector(requestDidFail:)];
	[self.currentRequest startAsynchronous];
}

- (void)listDidFinish:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		NSString *responseMessage = [request responseString];
		NSArray *apps = [App appsWithXMLString:responseMessage];
		[self broadcast:@selector(herokuReceivedList:) withObject:apps];
	}
	else
	{
		[self requestDidFail:request];
	}
}

#pragma mark -
#pragma mark Info API

- (void)info:(NSString*)appName
{
	NSString *resource = [NSString stringWithFormat:@"apps/%@", appName];
	self.currentRequest = [self requestForResource:resource
										 didFinish:@selector(infoDidFinish:)
										   didFail:@selector(requestDidFail:)];
	[self.currentRequest startAsynchronous];
}

- (void)infoDidFinish:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		NSString *responseMessage = [request responseString];
		[self broadcast:@selector(herokuReceivedInfo:) withObject:responseMessage];
	}
	else
	{
		[self requestDidFail:request];
	}
}

#pragma mark -
#pragma mark Installed Addons API

- (void)installedAddons:(NSString*)appName
{
	NSString *resource = [NSString stringWithFormat:@"apps/%@/addons", appName];
	self.currentRequest = [self requestForResource:resource
										 didFinish:@selector(installedAddonsDidFinish:)
										   didFail:@selector(requestDidFail:)
									   contentType:@"application/json"];
	[self.currentRequest startAsynchronous];
}

- (void)installedAddonsDidFinish:(ASIHTTPRequest *)request
{
	if (200 == request.responseStatusCode)
	{
		id json = [[request responseString] JSONValue];
		[self broadcast:@selector(herokuReceivedInstalledAddons:) withObject:json];
	}
	else
	{
		[self requestDidFail:request];
	}
}

#pragma mark -
#pragma mark Available Addons

- (void)addons
{
	self.currentRequest = [self requestForResource:@"addons"
										 didFinish:@selector(addonsDidFinish:)
										   didFail:@selector(requestDidFail:)
									   contentType:@"application/json"];
	[self.currentRequest startAsynchronous];
}

- (void)addonsDidFinish:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		id json = [[request responseString] JSONValue];
		[self broadcast:@selector(herokuReceivedAddons:) withObject:json];
	}
	else
	{
		[self requestDidFail:request];
	}
}

#pragma mark -
#pragma mark Logs API

- (void)logs:(NSString*)appName
{
	NSString *resource = [NSString stringWithFormat:@"apps/%@/logs?logplex=true", appName];
	self.currentRequest = [self requestForResource:resource
										 didFinish:@selector(logsDisambiguationDidFinish:)
										   didFail:@selector(requestDidFail:)];
	self.currentRequest.userInfo = [NSDictionary dictionaryWithObject:appName forKey:@"AppName"];
	[self.currentRequest startAsynchronous];
}

- (void)logsDisambiguationDidFinish:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		NSString *response = [request responseString];

		if ([response isEqual:@"Use old logs"])
		{
			NSString *resource = [NSString stringWithFormat:@"apps/%@/logs", [request.userInfo objectForKey:@"AppName"]];
			self.currentRequest = [self requestForResource:resource
												 didFinish:@selector(logsDidFinish:)
												   didFail:@selector(requestDidFail:)];
		}
		else
		{
			NSURL *URL = [NSURL URLWithString:response];

			if (URL)
			{
				self.currentRequest = [self requestForURL:URL didFinish:@selector(logsDidFinish:) didFail:@selector(requestDidFail:) contentType:@"application/xml"];
				self.currentRequest.validatesSecureCertificate = NO;
			}
			else
			{
				[self requestDidFail:request];
				return;
			}
		}

		[self.currentRequest startAsynchronous];
	}
	else
	{
		[self requestDidFail:request];
	}
}

- (void)logsDidFinish:(ASIHTTPRequest*)request
{
	[self broadcast:@selector(herokuReceivedLogs:) withObject:[request responseString]];
}

#pragma mark -
#pragma mark Cron Logs API

- (void)cronLogs:(NSString*)appName
{
    NSString *resource = [NSString stringWithFormat:@"apps/%@/logs?logplex=true&ps=cron.1", appName];
    self.currentRequest = [self requestForResource:resource didFinish:@selector(runServiceDidFinish:) didFail:@selector(requestDidFail:)];
	self.currentRequest.userInfo = [NSDictionary dictionaryWithObject:appName forKey:@"app_name"];
	[self.currentRequest startAsynchronous];
}

- (void)cronLogsDidFinish:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{

		[self broadcast:@selector(herokuReceivedCronLogs:) withObject:[request responseString]];
	}
	else
	{
		[self requestDidFail:request];
	}
}

#pragma mark -
#pragma mark Dynos API

- (void)setDynos:(int)number forApp:(NSString *)appName
{
	NSString *resource = [NSString stringWithFormat:@"apps/%@/dynos",appName];
	self.currentRequest = [self putRequestForResource:resource
										 withFormData:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",number] forKey:@"dynos"]];
	self.currentRequest.didFinishSelector = @selector(dynosDidFinish:);
	[self.currentRequest startAsynchronous];
}

- (void)dynosDidFinish:(ASIHTTPRequest*)request
{
 	if (200 == request.responseStatusCode)
	{
		NSNumber *number = [NSNumber numberWithInt:[[request responseString] intValue]];
		[self broadcast:@selector(herokuReceivedDynoConfirmation:) withObject:number];
	}
	else
	{
		[self requestDidFail:request];
	}
}

#pragma mark -
#pragma mark Workers API

- (void)setWorkers:(int)number forApp:(NSString*)appName
{
	NSString *resource = [NSString stringWithFormat:@"apps/%@/workers",appName];
	self.currentRequest = [self putRequestForResource:resource
										 withFormData:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",number] forKey:@"workers"]];
	self.currentRequest.didFinishSelector = @selector(workersDidFinish:);

	[self.currentRequest startAsynchronous];
}

- (void)workersDidFinish:(ASIHTTPRequest*)request
{
 	if (200 == request.responseStatusCode)
	{
		NSNumber *number = [NSNumber numberWithInt:[[request responseString] intValue]];
		[self broadcast:@selector(herokuReceivedWorkerConfirmation:) withObject:number];
	}
	else
	{
		[self requestDidFail:request];
	}
}

#pragma mark -
#pragma mark Collaborators API

- (void)collaborators:(NSString*)appName
{
	NSString *resource = [NSString stringWithFormat:@"apps/%@/collaborators", appName];
	self.currentRequest = [self requestForResource:resource
										 didFinish:@selector(collaboratorsDidFinish:)
										   didFail:@selector(requestDidFail:)];
	[self.currentRequest startAsynchronous];
}

- (void)collaboratorsDidFinish:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		CXMLDocument *doc = [[CXMLDocument alloc] initWithXMLString:[request responseString] options:0 error:NULL];
		NSArray *nodes = [doc nodesForXPath:@"//collaborators/collaborator" error:nil];

		NSMutableArray *collaborators = [NSMutableArray array];

		for (CXMLElement *elt in nodes)
		{
			NSString *access = [[[elt elementsForName:@"access"] objectAtIndex:0] stringValue];
			NSString *email = [[[elt elementsForName:@"email"] objectAtIndex:0] stringValue];

			[collaborators addObject:[NSDictionary dictionaryWithObjectsAndKeys:access,kCollaboratorAccessKey,email,kCollaboratorEmailKey,nil]];
		}
		[self broadcast:@selector(herokuReceivedCollaborators:) withObject:collaborators];
	}
	else
	{
		[self requestDidFail:request];
	}
}

- (void)addCollaborator:(NSString*)email toApp:(NSString*)app
{
	NSString *resource = [NSString stringWithFormat:@"apps/%@/collaborators",app];
	self.currentRequest = [self postRequestForResource:resource withFormDictionary:[NSDictionary dictionaryWithObject:email forKey:@"collaborator[email]"]];
	self.currentRequest.didFinishSelector = @selector(addCollaboratorFinished:);
	[self.currentRequest startAsynchronous];
}

- (void)addCollaboratorFinished:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		[self broadcast:@selector(herokuAddedCollaborator:) withObject:[request responseString]];
	}
	else
	{
		[self requestDidFail:request];
	}
}

- (void)removeCollaborator:(NSString*)email fromApp:(NSString*)app
{
	NSString *resource = [NSString stringWithFormat:@"apps/%@/collaborators/%@",app, [email reallyURLEscape]];
	self.currentRequest = [self deleteRequestForResource:resource didFinish:@selector(removeCollaboratorFinished:) didFail:@selector(requestDidFail:)];
	[self.currentRequest startAsynchronous];
}

- (void)removeCollaboratorFinished:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		[self broadcast:@selector(herokuRemovedCollaborator:) withObject:[request responseString]];
	}
	else
	{
		[self requestDidFail:request];
	}
}

#pragma mark -
#pragma mark Maintenance Mode API

- (void)changeMaintenanceMode:(BOOL)yn forApp:(NSString*)appName
{
	NSString *resource = [NSString stringWithFormat:@"apps/%@/server/maintenance",appName];
	NSDictionary *formData = [NSDictionary dictionaryWithObject:(yn ? @"1" : @"0") forKey:@"maintenance_mode"];
	self.currentRequest = [self postRequestForResource:resource withFormDictionary:formData];
	self.currentRequest.didFinishSelector = @selector(maintenanceDidFinish:);

	[self.currentRequest startAsynchronous];
}

- (void)maintenanceDidFinish:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		[self broadcast:@selector(herokuMaintenanceModeChanged:) withObject:[request responseString]];
	}
	else
	{
		[self requestDidFail:request];
	}
}

#pragma mark -
#pragma mark Services

- (void)runService:(NSString*)command forApp:(NSString*)appName
{
	NSString *resource = [NSString stringWithFormat:@"apps/%@/services",appName];

	self.currentRequest = [self postRequestForResource:resource withFormData:[command dataUsingEncoding:NSUTF8StringEncoding]];
    [self.currentRequest addRequestHeader:@"Content-Type" value:@"text/plain"];
	self.currentRequest.didFinishSelector = @selector(runServiceDidFinish:);
	self.currentRequest.userInfo = [NSDictionary dictionaryWithObject:appName forKey:@"app_name"];
	[self.currentRequest startAsynchronous];
}

- (void)runServiceDidFinish:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		NSURL *chunkURL = [NSURL URLWithString:[request responseString]];
		[self readChunkFromURL:chunkURL forAppName:[request.userInfo objectForKey:@"app_name"] withResults:@""];
	}
	else
	{
		[self requestDidFail:request];
	}
}

- (void)deferredReadChunk:(NSTimer*)timer
{
	NSDictionary *userInfo = [timer userInfo];
	NSURL *url = [userInfo objectForKey:@"url"];
	NSString *appName = [userInfo objectForKey:@"app_name"];
	NSString *results = [userInfo objectForKey:@"results"];

	[self readChunkFromURL:url forAppName:appName withResults:results];
}

- (void)readChunkFromURL:(NSURL*)url forAppName:(NSString*)appName withResults:(NSString*)results
{
	self.currentRequest = [[ASIHTTPRequest alloc] initWithURL:url];
	[self addHeadersToRequest:self.currentRequest];

    if ([url user])
    {
        [self.currentRequest addRequestHeader:@"Authorization"
                                        value:[NSString stringWithFormat:@"Basic %@", [ASIHTTPRequest base64forData:[[NSString stringWithFormat:@"%@",[url user]]
                                                                                                                     dataUsingEncoding:NSUTF8StringEncoding]]]];
    }

	self.currentRequest.delegate = self;
	self.currentRequest.didFailSelector = @selector(didReadChunk:);
	self.currentRequest.didFinishSelector = @selector(didReadChunk:);

	self.currentRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:appName,@"app_name",results,@"results", nil];
	[self.currentRequest startAsynchronous];
}

- (void)didReadChunk:(ASIHTTPRequest*)request
{
	if (204 == request.responseStatusCode)
	{
		//Back off for a second.
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:request.url,@"url",
							  [request.userInfo objectForKey:@"app_name"],@"app_name",
							  [request.userInfo objectForKey:@"results"], @"results", nil];
		[NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(deferredReadChunk:) userInfo:info repeats:NO];
	}
	else if (200 == request.responseStatusCode)
	{
		NSString *nextLocation = [request.responseHeaders objectForKey:@"Location"];
		NSMutableString *results = [NSMutableString stringWithString:[request.userInfo objectForKey:@"results"]];
		NSString *appName = [request.userInfo objectForKey:@"app_name"];
		[results appendString:[request responseString]];

		[self readChunkFromURL:[NSURL URLWithString:nextLocation] forAppName:appName withResults:results];
	}
	else if (0 == request.responseStatusCode)
	{
		[self broadcast:@selector(herokuRunServiceFinished:) withObject:[request.userInfo objectForKey:@"results"]];
	}
	else
	{
		[self requestDidFail:request];
	}
}

#pragma mark -
#pragma mark PS API

- (void)processes:(NSString*)appName
{
	NSString *resource = [NSString stringWithFormat:@"apps/%@/ps", appName];
	self.currentRequest = [self requestForResource:resource
										 didFinish:@selector(processesDidFinish:)
										   didFail:@selector(requestDidFail:)
									   contentType:@"application/json"];

	[self.currentRequest startAsynchronous];
}

- (void)processesDidFinish:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		[self broadcast:@selector(herokuReceivedPSOutput:) withObject:[[request responseString] JSONValue]];
	}
	else
	{
		[self requestDidFail:request];
	}
}

#pragma mark -
#pragma mark Restart API

- (void)restart:(NSString*)appName
{
	NSString *resource = [NSString stringWithFormat:@"apps/%@/server", appName];
	self.currentRequest = [self deleteRequestForResource:resource
											   didFinish:@selector(restartDidFinish:)
												 didFail:@selector(requestDidFail:)];
	[self.currentRequest startAsynchronous];
}

- (void)restartDidFinish:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		[self broadcast:@selector(herokuRestarted:) withObject:[request responseString]];
	}
	else
	{
		[self requestDidFail:request];
	}
}

#pragma mark -
#pragma mark One-off Console Command

- (void)executeCommand:(NSString*)command forApp:(NSString*)appName
{
	NSData *data = [command dataUsingEncoding:NSUTF8StringEncoding];
	NSString *resource = [NSString stringWithFormat:@"apps/%@/console", appName];
	self.currentRequest = [self postRequestForResource:resource withFormData:data];
	self.currentRequest.didFinishSelector = @selector(executeCommandDidFinish:);
	[self.currentRequest startAsynchronous];
}

- (void)executeCommandDidFinish:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		NSString *result = [request responseString];
		[self broadcast:@selector(herokuCommandFinished:) withObject:[result JSONValue]];
	}
	else
	{
		[self requestDidFail:request];
	}
}

#pragma mark -
#pragma mark Console Sessions

- (void)consoleTTYForApp:(NSString*)appName
{
	NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.heroku.com/apps/%@/consoles", appName]];
	self.currentRequest = [[ASIHTTPRequest alloc] initWithURL:URL];
	self.currentRequest.requestMethod = @"POST";
	[self addHeadersToRequest:self.currentRequest];
	self.currentRequest.delegate = self;
	self.currentRequest.didFailSelector = @selector(consoleTTYDidFinish:);
	self.currentRequest.didFinishSelector = @selector(consoleTTYDidFinish:);
	[self.currentRequest startAsynchronous];
}

- (void)consoleTTYDidFinish:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		[self broadcast:@selector(herokuConsoleTTYFinished:) withObject:[request responseString]];
	}
	else
	{
		[self broadcast:@selector(herokuConsoleTTYError:) withObject:request];
	}
}

- (void)consoleCommand:(NSString*)cmd forApp:(NSString*)appName withConsoleID:(NSString*)consoleID
{
	NSString *resource = [NSString stringWithFormat:@"apps/%@/consoles/%@/command",appName, consoleID];
	self.currentRequest = [self postRequestForResource:resource withFormData:[cmd dataUsingEncoding:NSUTF8StringEncoding]];
	self.currentRequest.didFinishSelector = @selector(commandDidFinish:);
	[self.currentRequest startAsynchronous];
}

- (void)commandDidFinish:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		[self broadcast:@selector(herokuCommandFinished:) withObject:[request responseString]];
	}
	else
	{
		[self broadcast:@selector(herokuCommandError:) withObject:request];
	}
}

- (void)deleteConsole:(NSString*)consoleID forApp:(NSString*)appName
{
	NSString *resource = [NSString stringWithFormat:@"apps/%@/consoles/%@",appName, consoleID];
	ASIHTTPRequest *request = [self deleteRequestForResource:resource didFinish:@selector(noop:) didFail:@selector(noop:)];
	[request startAsynchronous];
}

- (void)noop:(ASIHTTPRequest*)r
{
	NSLog(@"noop %d", r.responseStatusCode);
}

#pragma mark -
#pragma mark Config Variables

- (void)configVarsForApp:(NSString*)appName
{
	NSString *resource = [NSString stringWithFormat:@"apps/%@/config_vars", appName];
	self.currentRequest = [self requestForResource:resource didFinish:@selector(configVarsDidFinish:) didFail:@selector(requestDidFail:) contentType:@"application/json"];
	[self.currentRequest startAsynchronous];
}

- (void)configVarsDidFinish:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		[self broadcast:@selector(herokuConfigVarsDidFinish:) withObject:[[request responseString] JSONValue]];
	}
	else
	{
		[self requestDidFail:request];
	}
}

- (void)addConfigVariableWithKey:(NSString*)key value:(NSString*)value forApp:(NSString*)app
{
	NSString *resource = [NSString stringWithFormat:@"apps/%@/config_vars", app];
	NSData *data = [[NSString stringWithFormat:@"{\"%@\":\"%@\"}",key,value] dataUsingEncoding:NSUTF8StringEncoding];
	self.currentRequest = [self postRequestForResource:resource withFormData:data];
	self.currentRequest.requestMethod = @"PUT";
	self.currentRequest.didFinishSelector = @selector(addConfigVariableDidFinish:);
	[self.currentRequest startAsynchronous];
}

- (void)addConfigVariableDidFinish:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		[self broadcast:@selector(herokuAddedConfigVariable:) withObject:[request responseString]];
	}
	else
	{
		[self requestDidFail:request];
	}
}

- (void)removeConfigVariable:(NSString*)key forApp:(NSString*)app
{
	NSString *resource = [NSString stringWithFormat:@"apps/%@/config_vars/%@", app, key];
	self.currentRequest = [self deleteRequestForResource:resource didFinish:@selector(deleteConfigVariableDidFinish:) didFail:@selector(requestDidFail:)];
	[self.currentRequest startAsynchronous];
}

- (void)deleteConfigVariableDidFinish:(ASIHTTPRequest*)request
{
	if (200 == request.responseStatusCode)
	{
		[self broadcast:@selector(herokuRemovedConfigVariable:) withObject:[request responseString]];
	}
	else
	{
		[self requestDidFail:request];
	}
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self.currentRequest cancel];
	self.delegate = NULL;
}

@end
