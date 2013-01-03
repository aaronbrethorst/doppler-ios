//
//  ConfigVariableDelegate.h
//  heroku
//
//  Created by Aaron Brethorst on 8/9/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConfigVariableDelegate<NSObject>
- (void)reload;
@end
