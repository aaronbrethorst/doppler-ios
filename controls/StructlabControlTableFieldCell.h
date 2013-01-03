//
//  StructlabControlTableFieldCell.h
//  FiveStar
//
//  Created by Aaron Brethorst on 6/23/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StructlabControlTableFieldCell : UITableViewCell
{
	UIView *control;
}
+ (CGFloat)rowHeight;
@property (nonatomic, retain) UIView *control;

@end
