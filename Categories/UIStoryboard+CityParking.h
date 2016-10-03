//
//  UIStoryboard+CityParking.h
//  CityParking
//
//  Created by Igor on 22.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (CityParking)

+ (UIViewController *)cp_viewControllerWithIdentifier:(NSString *)identifier;
+ (UIViewController *)cp_viewControllerWithIdentifier:(NSString *)identifier fromStoryboardName:(NSString *)storyboardName;

@end
