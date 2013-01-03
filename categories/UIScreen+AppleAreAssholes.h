//
//  UIScreen+AppleAreAssholes.h
//  heroku
//
//  Created by Aaron Brethorst on 8/11/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScreen (AppleAreAssholes)
+ (CGRect) convertRect:(CGRect)rect toView:(UIView *)view;
@end
