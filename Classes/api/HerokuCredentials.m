//
//  HerokuCredentials.m
//  heroku
//
//  Created by Aaron Brethorst on 7/26/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "HerokuCredentials.h"
#import "SFHFKeychainUtils.h"

@implementation HerokuCredentials

@synthesize usernames;

+ (HerokuCredentials*)sharedHerokuCredentials
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[HerokuCredentials alloc] init];
    });
    return _sharedObject;
}

- (id)init
{
	if (self = [super init])
	{
		credentials = [[NSMutableDictionary alloc] init];
		usernames = [[NSMutableArray alloc] init];
		[usernames addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"usernames"]];
	}
	return self;
}

- (BOOL)isEmpty
{
	return ([usernames count] == 0);
}

- (void)deleteUserAtIndex:(int)index
{
	NSString *username = [usernames objectAtIndex:index];
	[usernames removeObjectAtIndex:index];
	
	[credentials removeObjectForKey:username];
	[SFHFKeychainUtils deleteItemForUsername:username andServiceName:@"com.structlab.heroku" error:nil];
	
	[[NSUserDefaults standardUserDefaults] setObject:usernames forKey:@"usernames"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeAllPasswords
{
	[credentials removeAllObjects];
	
	for (NSString *u in usernames)
	{
		[SFHFKeychainUtils deleteItemForUsername:u andServiceName:@"com.structlab.heroku" error:nil];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NukeHerokuPasswords" object:nil];
}

- (void)addUsername:(NSString*)username password:(NSString*)password savePassword:(BOOL)yn
{
	[credentials setObject:password forKey:username];
	if (yn)
	{
		[SFHFKeychainUtils storeUsername:username andPassword:password forServiceName:@"com.structlab.heroku" updateExisting:YES error:nil];
	}
	
	if (NSNotFound == [usernames indexOfObject:username])
	{
		[usernames addObject:username];
	}	
	
	[[NSUserDefaults standardUserDefaults] setObject:usernames forKey:@"usernames"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)passwordForUsername:(NSString*)username
{
	NSString *pass = [credentials objectForKey:username];
	
	if (pass)
	{
		return pass;
	}
	else
	{
		return [SFHFKeychainUtils getPasswordForUsername:username andServiceName:@"com.structlab.heroku" error:nil];
	}
}

- (void)firstLaunch15CredentialNuke
{
    if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:@"NukedCredentialsForAPIKeyTransition"])
    {
        [self removeAllPasswords];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NukedCredentialsForAPIKeyTransition"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end