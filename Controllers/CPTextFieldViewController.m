//
//  CPTextFieldViewController.m
//  CityParking
//
//  Created by Igor Zubko on 03.12.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPTextFieldViewController.h"
// Categories
#import "NSArray+CPUtils.h"

static const NSInteger kConfigMaxWordsCount = 25;

@interface CPTextFieldViewController () <UITextViewDelegate>
@property (nonatomic, retain) UITextView *textField;
@end

@implementation CPTextFieldViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = RGBCOLOR(249, 249, 249);
	
	// Create text field
	self.textField = [[UITextView alloc] initWithFrame:self.view.bounds];
	self.textField.font = [UIFont systemFontOfSize:18];
	self.textField.textColor = kConfigBlackTextColor;
	self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.textField.keyboardType = UIReturnKeyDone;
	self.textField.delegate = self;
	
	[self.view addSubview:self.textField];
	
	// Create save button
	UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil)
																	  style:UIBarButtonItemStylePlain
																	 target:self
																	 action:@selector(actSave:)];
	self.navigationItem.rightBarButtonItem = anotherButton;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self->_success = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboarWillShowNotificaiton:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboarWillHideNotificaiton:) name:UIKeyboardWillHideNotification object:nil];
	
	self.textField.text = self.editibleText;
	[self setCurrentWordsCount:[self wordsCount:self.editibleText]];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.textField becomeFirstResponder];
}

#pragma mark - Keyboard notifications

- (void)keyboarWillShowNotificaiton:(NSNotification *)notification
{
	NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	CGRect newTextFieldFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetHeight(keyboardFrame));
							
	[UIView animateWithDuration:animationDuration animations:^{
		self.textField.frame = newTextFieldFrame;
	}];
}

- (void)keyboarWillHideNotificaiton:(NSNotification *)notification
{
	NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	
	CGRect newTextFieldFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
	
	[UIView animateWithDuration:animationDuration animations:^{
		self.textField.frame = newTextFieldFrame;
	}];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
	[theTextField resignFirstResponder];
	return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
	NSInteger wordsCount = [self wordsCount:newText];
	
//	if (wordsCount <= kConfigMaxWordsCount)
//	{
//		[self setCurrentWordsCount:wordsCount];
//		return YES;
//	}
//	
//	NSInteger oldWordsCount = [self wordsCount:textView.text];
//	if (wordsCount <= oldWordsCount)
//	{
//		return YES;
//	}
//	
//	return NO;
	
	[self setCurrentWordsCount:wordsCount];
	
	return YES;
}

#pragma mark - Helpers

- (void)setCurrentWordsCount:(NSInteger)wordsCount
{
	self.navigationItem.rightBarButtonItem.enabled = /*(wordsCount > 0) &&*/ (wordsCount <= kConfigMaxWordsCount);
	self.title = [NSString stringWithFormat:NSLocalizedString(@"Words %d/25", nil), wordsCount];
}

- (NSInteger)wordsCount:(NSString *)text
{
	if (text.length == 0) {
		return 0;
	}
	
	NSArray *words = [text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"!@#$%^&*()_+|;':\",./<> \\? \n"]];
	NSArray *filterad = [words cp_filter:^BOOL(NSString *item) {
		return item.length > 0;
	}];
	
	return filterad.count;
}

#pragma mark - Actions

- (void)actSave:(id)sender
{
	self->_success = YES;
	self->_editibleText = self.textField.text;
	
	[self.navigationController popViewControllerAnimated:YES];
}

@end
