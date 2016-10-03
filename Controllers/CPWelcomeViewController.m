//
//  CPWelcomeViewController.m
//  CityParking
//
//  Created by Igor on 27.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import "CPWelcomeViewController.h"
// Classes
#import "CPMainMenuViewController.h"
// Views
#import "CPBorderedButton.h"
#import "CPButtonWithRightArrow.h"
// Seervices
#import "CPAnalitics.h"
#import "CPUserService.h"
// Categories
#import "UIStoryboard+CityParking.h"

static NSString * const kDefaultAvatarPlaceholder = @"imgAvatarPlaceholder.png";

@interface CPWelcomeViewController ()
@property (weak, nonatomic) IBOutlet CPButtonWithRightArrow *btnPostSpot;
@property (weak, nonatomic) IBOutlet CPButtonWithRightArrow *btnRentSpot;

@property (weak, nonatomic) IBOutlet UIImageView *imgViewUserAvatar;
@property (weak, nonatomic) IBOutlet UILabel *labelNotSigned;

@property (weak, nonatomic) IBOutlet UIView *authorizeViewContainer;

@end

@implementation CPWelcomeViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	DASSERTWARNING(self.analiticsService != nil);
	
	self.btnRentSpot.bottomBorderColor = RGBACOLOR(136, 80, 43, 0.6);
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self updateUI];
	
	[self.analiticsService trackOpeningScreen:@"Welcome Screen" withParams:nil];
}

#pragma mark - Actions

- (IBAction)actPostASpot:(id)sender
{
	CPMainMenuViewController *vc = (id)[UIStoryboard cp_viewControllerWithIdentifier:@"MainMenuScreen"];
	[vc showViewControllerById:kMainMenuControllerPostSpot storyboard:@"Main" animated:NO];
	DASSERT([vc isKindOfClass:[CPMainMenuViewController class]]);
	[self showViewController:vc animated:YES];
}

- (IBAction)actRentASpot:(id)sender
{
	CPMainMenuViewController *vc = (id)[UIStoryboard cp_viewControllerWithIdentifier:@"MainMenuScreen"];
	[vc showViewControllerById:kMainMenuControllerSearchSpot storyboard:@"Main" animated:NO];
	DASSERT([vc isKindOfClass:[CPMainMenuViewController class]]);
	[self showViewController:vc animated:YES];
}

#pragma mark - Helpers

- (void)showViewController:(UIViewController *)vc animated:(BOOL)animated
{
	self.view.window.rootViewController = vc;
	
	if (animated)
	{
		[vc addChildViewController:self];
		[vc.view addSubview:self.view];

		self.view.window.rootViewController = vc;
		
		__weak typeof(self) weakSelf = self;
		[UIView animateWithDuration:0.15f animations:^{
			weakSelf.view.alpha = 0.f;
		} completion:^(BOOL finished) {
			[weakSelf.view removeFromSuperview];
			[weakSelf removeFromParentViewController];
		}];
	}
}

- (void)updateUI
{
	self.labelNotSigned.hidden = [self.userService.currentUser isAuthorized];
	self.authorizeViewContainer.hidden = [self.userService.currentUser isAuthorized];
}

@end
