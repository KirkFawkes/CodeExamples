//
//  CPViewController.m
//  CityParking
//
//  Created by Igor on 22.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import "CPViewController.h"
#import "CPMainMenuViewController.h"
// Services
#import "CPNetworkIndicatorService.h"
#import "CPNetworkService.h"
#import "CPAnalitics.h"
#import "CPAppearance.h"
#import "CPUserService.h"
#import "CPRouterService.h"
// Other
#import <MBProgressHUD/MBProgressHUD.h>

@interface CPViewController ()
@end

@implementation CPViewController

+ (instancetype)viewController
{
	@throw @"Override this method in child";
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if (self.navigationController.viewControllers.count == 1 && self.dontShowMainMenu==NO) {
		[self addMenuButton];
	}
}

#pragma mark -

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if ([self.delegate respondsToSelector:@selector(viewControllerWillDisappear:)]) {
		[self.delegate viewControllerWillDisappear:self];
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	if ([self.delegate respondsToSelector:@selector(viewControllerDidDisappear:)]) {
		[self.delegate viewControllerDidDisappear:self];
	}
}

#pragma mark -

- (void)addMenuButton
{
	UIImage *menuImage = [UIImage imageNamed:@"btnMainMenu.png"];
	CGRect menuButtonFrame = CGRectInset(CGRectMake(0, 10, menuImage.size.width, menuImage.size.height), -15, -10);
	UIButton *menuButton = [[UIButton alloc] initWithFrame:menuButtonFrame];
	[menuButton addTarget:self action:@selector(showMainMenu:) forControlEvents:UIControlEventTouchUpInside];
	[menuButton setImage:menuImage forState:UIControlStateNormal];
	
	UIView *menuButtonWrapper = [[UIView alloc] initWithFrame:menuButtonFrame];
	[menuButtonWrapper addSubview:menuButton];
	
	UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	[negativeSpacer setWidth:-11];
	
	self.navigationItem.leftBarButtonItems = @[negativeSpacer, [[UIBarButtonItem alloc] initWithCustomView:menuButtonWrapper]];
}

- (IBAction)showMainMenu:(id)sender
{
	[self willShowMainMenu];
	[[NSNotificationCenter defaultCenter] postNotificationName:kMainMenuViewContollerShow object:self];
}

- (void)willShowMainMenu
{
	// Can be ovverided in child
}

- (void (^)(NSError *error))defaultErrorBlock
{
	return ^(NSError *error) {
		if ([error.userInfo[@"silent"] integerValue] == 0)
		{
			NSString *errorMessage = [[error.userInfo allValues] firstObject];
			
			if ([errorMessage isKindOfClass:[NSError class]])
			{
				NSError *err = (NSError *)errorMessage;
				
				NSString *text = err.localizedDescription;
				NSString *reason = err.localizedFailureReason;
				
				errorMessage = (reason.length > 0) ? [NSString stringWithFormat:@"%@\n\n%@", text, reason] : text;
			} else if (errorMessage.length == 0) {
				errorMessage = error.localizedDescription;
			}
			
			[self.analiticsService trackError:error.localizedDescription withMessage:errorMessage andError:error];
		
			[self alertWithTitle:NSLocalizedString(@"Error", nil) andMessage:errorMessage];
		}
	};
}

- (void (^)(NSString *message))defaultAlertBlock
{
	return ^(NSString *message) {
		[self alertWithTitle:@"" andMessage:message];
	};
}

- (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
}

- (void)showWithParams:(id)params
{
	DLOG(@"Not implemented");
}

- (void)notifyParentWithResult:(id)result
{
	if ([self.delegate respondsToSelector:@selector(viewController:finishedWithResult:)]) {
		[self.delegate viewController:self finishedWithResult:result];
	}
}

#pragma mark - HUD

- (void)setLoadingScreenVisible:(BOOL)loadingScreenVisible
{
	[self setLoadingScreenVisible:loadingScreenVisible fullScreen:YES];
}

- (void)setLoadingScreenVisible:(BOOL)loadingScreenVisible fullScreen:(BOOL)fullscreen
{
	DASSERT(self->_loadingScreenVisible != loadingScreenVisible);
	
	self->_loadingScreenVisible = loadingScreenVisible;
	
	UIView *view = nil;
	if (fullscreen) {
		view = (self.navigationController ? self.navigationController.view : self.view.window);
	} else {
		view = self.view;
	}
	
	if (loadingScreenVisible)
	{
		MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
		hud.dimBackground = YES;
	} else {
		[MBProgressHUD hideHUDForView:view animated:YES];
	}
}

@end
