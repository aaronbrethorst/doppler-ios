//
//  HerokuCredentials.h
//  heroku
//
//  Created by Aaron Brethorst on 7/26/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HerokuCredentials : NSObject
{
	NSMutableDictionary *credentials;
	NSMutableArray *usernames;
}
@property(nonatomic,readonly) NSMutableArray *usernames;
+ (id)sharedHerokuCredentials;
- (void)addUsername:(NSString*)username password:(NSString*)password savePassword:(BOOL)yn;
- (NSString*)passwordForUsername:(NSString*)username;
- (BOOL)isEmpty;
- (void)removeAllPasswords;
- (void)deleteUserAtIndex:(int)index;
- (void)firstLaunch15CredentialNuke;
@end
