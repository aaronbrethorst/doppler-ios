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
	id<PickerViewControllerDelegate> __weak delegate;
	NSString *subject;
	int initialValue;
	int currentValue;
	UILabel *subjectLabel;
	BOOL allowsZero;
}
@property(nonatomic,assign) BOOL allowsZero;
@property(nonatomic,assign) int initialValue;
@property(nonatomic,strong) NSString *subject;
@property(nonatomic,weak) id<PickerViewControllerDelegate> delegate;
@property(nonatomic,strong) IBOutlet UIPickerView *picker;
@property(nonatomic,strong) IBOutlet UILabel *subjectLabel;
@end
