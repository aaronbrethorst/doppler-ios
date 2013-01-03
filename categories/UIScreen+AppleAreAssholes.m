//
//  UIScreen+AppleAreAssholes.m
//  heroku
//
//  Created by Aaron Brethorst on 8/11/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "UIScreen+AppleAreAssholes.h"

@implementation UIScreen (AppleAreAssholes)

+ (CGRect)convertRect:(CGRect)rect toView:(UIView *)view
{
    UIWindow *window = [view isKindOfClass:[UIWindow class]] ? (UIWindow *) view : [view window];
    return [view convertRect:[window convertRect:rect fromWindow:nil] fromView:nil];
}
@end
