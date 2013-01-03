//
//  UIViewController+Additions.m
//  heroku
//
//  Created by Aaron Brethorst on 9/25/11.
//  Copyright 2011 Structlab LLC. All rights reserved.
//

#import "UIViewController+Additions.h"

@implementation UIViewController (Additions)
- (void)showLoadingUI
{
	[self showLoadingUIWithText:NSLocalizedString(@"Loading...",@"")];
}

- (void)showLoadingUIWithText:(NSString*)text
{
    [SVProgressHUD showWithStatus:text];
}

- (void)hideLoadingUI
{
    [SVProgressHUD dismiss];
}
@end
