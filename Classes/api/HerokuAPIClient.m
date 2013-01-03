//
//  HerokuAPIClient.m
//  heroku
//
//  Created by Aaron Brethorst on 9/25/11.
//  Copyright 2011 Structlab LLC. All rights reserved.
//

#import "HerokuAPIClient.h"

NSString * const kHerokuBaseURLString = @"https://api.heroku.com/";

@implementation HerokuAPIClient

+ (HerokuAPIClient *)sharedClient {
    static HerokuAPIClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kHerokuBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];

    if (!self) {
        return nil;
    }
    
    [self setDefaultHeader:@"X-Heroku-Api-Version" value:@"2"];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    //[self setDefaultHeader:@"Accept" value:@"*/*; q=0.5, application/xml"];
	[self setDefaultHeader:@"User-Agent" value:@"heroku-gem/2.3.6"];
	[self setDefaultHeader:@"X-ruby-version" value:@"1.9.2"];
	[self setDefaultHeader:@"X-ruby-platform" value:@"x86_64-darwin11.0.0"];

    return self;
}

#pragma mark - Login

- (void)loginWithUsername:(NSString*)aUsername password:(NSString*)aPassword success:(void (^)(id response))success failure:(void (^)(NSError *error))failure
{
    [self postPath:@"login" parameters:[NSDictionary dictionaryWithObjectsAndKeys:aUsername, @"username", aPassword, @"password", nil] success:success failure:failure];
}

#pragma mark - Dynos

- (void)setBambooApp:(NSString*)app dynos:(int)dynos success:(void (^)(id response))success failure:(void (^)(NSError *error))failure
{
    [self putPath:[NSString stringWithFormat:@"apps/%@/dynos", app]
       parameters:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:dynos] forKey:@"dynos"]
          success:success failure:failure];
}

- (void)setBambooApp:(NSString*)app workers:(int)workers success:(void (^)(id response))success failure:(void (^)(NSError *error))failure
{
    [self putPath:[NSString stringWithFormat:@"apps/%@/workers", app]
       parameters:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:workers] forKey:@"workers"]
          success:success failure:failure];
}

@end
