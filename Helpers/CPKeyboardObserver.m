//
//  CPKeyboardObserver.m
//  CityParking
//
//  Created by Igor on 21.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import "CPKeyboardObserver.h"

@interface CPKeyboardObserver ()
@property (nonatomic, assign) BOOL opened;
@end

static UIViewAnimationOptions CPKeyboardAnimationOptionsWithCurve(UIViewAnimationCurve curve)
{
	switch (curve)
	{
		case UIViewAnimationCurveEaseInOut:
			return UIViewAnimationOptionCurveEaseInOut;
		case UIViewAnimationCurveEaseIn:
			return UIViewAnimationOptionCurveEaseIn;
		case UIViewAnimationCurveEaseOut:
			return UIViewAnimationOptionCurveEaseOut;
		case UIViewAnimationCurveLinear:
		default:
			return UIViewAnimationOptionCurveLinear;
	}
}

static CPKeyboardChange CPKeyboardChangeFromDictionary(NSDictionary *dict)
{
	UIViewAnimationCurve curve = (UIViewAnimationCurve)[[dict valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
	
	return (CPKeyboardChange) {
		.beginRect = [[dict valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue],
		.endRect = [[dict valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue],
		.duration = [[dict valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue],
		.animationCurve = curve,
		.animationOptions = CPKeyboardAnimationOptionsWithCurve(curve)
	};
}

@implementation CPKeyboardObserver

- (instancetype)initWithDelegate:(id<CPKeyboardObserverDelegate>)delegate
{
	if (self = [super init])
	{
		self->_delegate = delegate;
	}
	
	return self;
}

- (void)dealloc
{
	[self stop];
}

#pragma mark - Properties

- (BOOL)isOpened
{
	return self.opened;
}

#pragma mark -

- (void)start
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	[notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(keyboardDidShow:)  name:UIKeyboardDidShowNotification object:nil];
	
	[notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(keyboardDidHide:)  name:UIKeyboardDidHideNotification object:nil];
	
//	[notificationCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
//	[notificationCenter addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)stop
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
	[self sendWillChangeNotification:notification.userInfo];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
	self.opened = YES;
	
	[self sendDidChangeNotification:notification.userInfo];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	[self sendWillChangeNotification:notification.userInfo];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
	self.opened = NO;
	[self sendDidChangeNotification:notification.userInfo];
}

#pragma mark - Helpers

- (void)sendWillChangeNotification:(NSDictionary *)change
{
	if ([self.delegate respondsToSelector:@selector(keyboardObserver:willChange:)])
	{
		self->_lastChange = CPKeyboardChangeFromDictionary(change);
		[self.delegate keyboardObserver:self willChange:self.lastChange];
	}
}

- (void)sendDidChangeNotification:(NSDictionary *)change
{
	if ([self.delegate respondsToSelector:@selector(keyboardObserver:didChange:)])
	{
		[self.delegate keyboardObserver:self didChange:CPKeyboardChangeFromDictionary(change)];
	}
}

@end
