//
//  UIViewController+Additions.h
//  heroku
//
//  Created by Aaron Brethorst on 9/25/11.
//  Copyright 2011 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Additions)
- (void)showLoadingUI;
- (void)showLoadingUIWithText:(NSString*)text;
- (void)hideLoadingUI;
@end
