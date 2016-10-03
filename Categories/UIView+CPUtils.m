//
//  UIView+CPUtils.m
//  CityParking
//
//  Created by Igor Zubko on 17.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "UIView+CPUtils.h"

@implementation UIView (CPUtils)

- (void)scrollToY:(CGFloat)y
{
	[UIView beginAnimations:@"scroll" context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25];
	self.transform = CGAffineTransformMakeTranslation(0, y);
	[UIView commitAnimations];
	
}

- (void)scrollToView:(UIView *)view
{
	CGRect theFrame = view.frame;
	CGFloat y = theFrame.origin.y - 15;
	y -= (y/1.8);
	[self scrollToY:-y];
}


- (void)scrollElement:(UIView *)view toPoint:(CGFloat)y
{
	CGRect theFrame = view.frame;
	CGFloat orig_y = theFrame.origin.y;
	CGFloat diff = y - orig_y;
	if (diff < 0) {
		[self scrollToY:diff];
	}
	else {
		[self scrollToY:0];
	}
}

@end
