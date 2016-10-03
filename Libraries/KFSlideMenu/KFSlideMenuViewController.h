//
//  KFSlideMenuViewController.h
//  CityParking
//
//  Created by Igor on 22.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KFSlideMenuViewController : UIViewController
@property (nonatomic, readonly) BOOL isOpened;
@property (nonatomic, retain) UIView *menuView;
@property (nonatomic, retain) UIViewController *rootViewController;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;

- (void)showMenu:(BOOL)show animated:(BOOL)animated;

@end
