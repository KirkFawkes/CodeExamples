//
//  UIView+CityParking.m
//  CityParking
//
//  Created by Igor on 28.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import "UIView+CityParking.h"

@implementation UIView (CityParking)

+ (instancetype)cp_loadViewFromNib
{
	NSString *nibName = NSStringFromClass([self class]);
	UIView *view = [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] firstObject];
	
	NSAssert(view != nil, @"View in nib not found");
	
	return view;
}
@end
