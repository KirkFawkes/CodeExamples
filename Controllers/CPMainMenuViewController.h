//
//  CPMainMenuViewController.h
//  CityParking
//
//  Created by Igor on 22.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPViewController.h"

extern NSString * const kMainMenuViewContollerShow;
extern NSString * const kMainMenuViewContollerHide;
extern NSString * const kMainMenuViewContollerShowAuthorization;

#pragma mark -

extern NSString * const kMainMenuViewContollerShowViewController;

#pragma mark - IDs

extern NSString * const kMainMenuControllerSearchSpot;
extern NSString * const kMainMenuControllerPostSpot;

@interface CPMainMenuViewController : CPViewController

- (void)showViewController:(UIViewController *)vc animated:(BOOL)animated;
- (void)showViewControllerById:(NSString *)viewController storyboard:(NSString *)storyboard animated:(BOOL)animated;

@end
