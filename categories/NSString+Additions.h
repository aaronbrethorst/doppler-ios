//
//  NSString+Additions.h
//  FiveStar
//
//  Created by Aaron Brethorst on 5/30/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)
- (NSString*)reallyURLEscape;
+ (NSString *)humanFormattedNumber:(int)theSize;
@end

@interface NSMutableString (Additions)
- (void)appendIfNotNil:(NSString*)text;
@end