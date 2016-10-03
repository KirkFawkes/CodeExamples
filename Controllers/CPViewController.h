//
//  CPViewController.h
//  CityParking
//
//  Created by Igor on 22.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "defines.h"

// service protocols
@protocol CPNetworkServiceProtocol, CPUserServiceProtocol, CPRouterServiceProtocol;
// classes
@class CPViewController;
@class CPNetworkActivityIndicatorService, CPAppearance, CPAnalitics, CPUserService, CPConfigService;

@protocol CPViewControllerDelegate <NSObject>
@optional
- (void)viewControllerWillDisappear:(CPViewController *)viewController;
- (void)viewControllerDidDisappear:(CPViewController *)viewController;

- (void)viewController:(CPViewController *)viewController finishedWithResult:(id)result;
@end

@interface CPViewController : UIViewController
@property (nonatomic, retain) id<CPViewControllerDelegate> delegate;  // WARNING! memory leaks. Need to fix later (check case "map" -> "book spot" -> "login")
// Local
@property (nonatomic, retain) /* Injected */ CPConfigService *configService;
@property (nonatomic, retain) /* Injected */ CPAppearance *appearanceService;
@property (nonatomic, retain) /* Injected */ CPNetworkActivityIndicatorService *activityIndicatorService;
@property (nonatomic, retain) /* Injected */ id<CPRouterServiceProtocol> routerService;
// Network
@property (nonatomic, retain) /* Injected */ id<CPNetworkServiceProtocol> networkService;
@property (nonatomic, retain) /* Injected */ CPAnalitics *analiticsService;
@property (nonatomic, retain) /* Injected */ id<CPUserServiceProtocol> userService;
// View
@property (nonatomic, assign) BOOL loadingScreenVisible;
@property (nonatomic, assign) BOOL dontShowMainMenu;

+ (instancetype)viewController;

- (void)showWithParams:(id)params;

- (void)addMenuButton;

- (IBAction)showMainMenu:(id)sender;

// Messages
- (void (^)(NSError *error))defaultErrorBlock;
- (void (^)(NSString *message))defaultAlertBlock;

- (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message;

// Handlers
- (void)willShowMainMenu;

- (void)notifyParentWithResult:(id)result;

// Activity indicator
- (void)setLoadingScreenVisible:(BOOL)loadingScreenVisible fullScreen:(BOOL)fullscreen;

@end
