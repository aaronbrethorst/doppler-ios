//
//  LoginViewControllerDelegate.h
//  heroku
//
//  Created by Aaron Brethorst on 7/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoginViewControllerDelegate
- (void)reloadCredentialsForUsername:(NSString*)username;
@end