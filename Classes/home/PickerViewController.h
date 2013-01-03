//
//  PickerViewController.h
//  heroku
//
//  Created by Aaron Brethorst on 7/24/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PickerViewController;

@protocol PickerViewControllerDelegate
- (void)pickerViewDidSelectNumber:(int)number forSubject:(NSString*)subject;
@end


@interface PickerViewController : UIViewController
{
	UIPickerView *picker;
	id<PickerViewControllerDelegate> delegate;
	NSString *subject;
	int initialValue;
	int currentValue;
	UILabel *subjectLabel;
	BOOL allowsZero;
}
@property(nonatomic,assign) BOOL allowsZero;
@property(nonatomic,assign) int initialValue;
@property(nonatomic,retain) NSString *subject;
@property(nonatomic,assign) id<PickerViewControllerDelegate> delegate;
@property(nonatomic,retain) IBOutlet UIPickerView *picker;
@property(nonatomic,retain) IBOutlet UILabel *subjectLabel;
@end
