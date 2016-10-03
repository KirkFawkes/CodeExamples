//
//  UIStoryboard+CityParking.m
//  CityParking
//
//  Created by Igor on 22.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import "UIStoryboard+CityParking.h"

#define kMainStoryboardName	@"Main"

@implementation UIStoryboard (CityParking)

+ (UIViewController *)cp_viewControllerWithIdentifier:(NSString *)identifier
{
	return [self cp_viewControllerWithIdentifier:identifier fromStoryboardName:kMainStoryboardName];
}

+ (UIViewController *)cp_viewControllerWithIdentifier:(NSString *)identifier fromStoryboardName:(NSString *)storyboardName
{
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
	return [storyboard instantiateViewControllerWithIdentifier:identifier];
}

@end
