//
//  HerokuAPIClient.h
//  heroku
//
//  Created by Aaron Brethorst on 9/25/11.
//  Copyright 2011 Structlab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

extern NSString * const kHerokuBaseURLString;

@interface HerokuAPIClient : AFHTTPClient
+ (HerokuAPIClient*)sharedClient;
- (id)initWithBaseURL:(NSURL *)url;

- (void)loginWithUsername:(NSString*)aUsername password:(NSString*)aPassword success:(void (^)(AFHTTPRequestOperation* operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation* operation, NSError *error))failure;
- (void)setBambooApp:(NSString*)app dynos:(int)dynos success:(void (^)(AFHTTPRequestOperation* operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation* operation, NSError *error))failure;
- (void)setBambooApp:(NSString*)app workers:(int)workers success:(void (^)(AFHTTPRequestOperation* operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation* operation, NSError *error))failure;
@end