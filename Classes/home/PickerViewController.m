//
//  PickerViewController.m
//  heroku
//
//  Created by Aaron Brethorst on 7/24/10.
//  Copyright 2010 Structlab LLC. All rights reserved.
//

#import "PickerViewController.h"

@interface PickerViewController ()
- (void)layoutPicker:(UIInterfaceOrientation)orientation;
@end


@implementation PickerViewController

@synthesize picker, delegate, subject, initialValue, subjectLabel, allowsZero;

- (void)viewDidLoad
{
	[super viewDidLoad];
	currentValue = self.initialValue;
	if (self.allowsZero)
	{
		[self.picker selectRow:self.initialValue inComponent:0 animated:NO];
	}
	else
	{
		[self.picker selectRow:(self.initialValue - 1) inComponent:0 animated:NO];
	}
	self.subjectLabel.text = [NSString stringWithFormat:@"Adjust the number of %@s your application needs.",[self.subject lowercaseString]];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)] autorelease];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	self.picker = NULL;
	self.subjectLabel = NULL;
}


- (void)dealloc
{
	self.subject = NULL;
	self.delegate = NULL;
	[super dealloc];
}

///////////


-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	// Layout once here to ensure the current orientation is respected.
	[self layoutPicker:[UIApplication sharedApplication].statusBarOrientation];
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	return (orientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationIsLandscape(orientation));
}

// Use frame of containing view to work out the correct origin and size of the UIDatePicker.
- (void)layoutPicker:(UIInterfaceOrientation)orientation
{
	CGFloat newPickerHeight = UIInterfaceOrientationIsLandscape(orientation) ? 170 : 216;
	picker.frame = CGRectMake(0,
								  self.view.frame.size.height - newPickerHeight, 
								  self.view.frame.size.width,
								  newPickerHeight);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
	[self layoutPicker:orientation];
}



///////////


#pragma mark -
#pragma mark IBActions

- (IBAction)cancel:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender
{
	[self.delegate pickerViewDidSelectNumber:currentValue forSubject:self.subject];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIPickerViewDelegate and UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (self.allowsZero)
	{
		return 25;
	}
	else
	{
		return 24;
	}
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (self.allowsZero)
	{
		if (0 == row)
		{
			return [NSString stringWithFormat:@"0 %@s", self.subject];
		}
		else if (1 == row)
		{
			return [NSString stringWithFormat:@"1 %@", self.subject];
		}
		else
		{
			return [NSString stringWithFormat:@"%d %@s", row, self.subject];
		}
	}
	else
	{
		return [NSString stringWithFormat:@"%d %@%@",row+1, self.subject, (row >= 1 ? @"s" : @"")];
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (self.allowsZero)
	{
		currentValue = row;
	}
	else
	{
		currentValue = row + 1;
	}
}


@end
