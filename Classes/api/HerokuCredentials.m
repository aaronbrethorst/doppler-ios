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

SYNTHESIZE_SINGLETON_FOR_CLASS(HerokuCredentials);

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
	NSString *username = [[usernames objectAtIndex:index] retain];
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