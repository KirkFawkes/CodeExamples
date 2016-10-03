//
//  KFSlideMenuViewController.m
//  CityParking
//
//  Created by Igor on 22.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import "KFSlideMenuViewController.h"
#import "KFSlideMenuOverlayView.h"

#define kSlideMenuPanTresholdPercent 0.2f

@interface KFSlideMenuViewController () <KFSlideMenuOverlayViewDelegate>
{
	CGFloat _overlayPercent;
}
@property (nonatomic, retain) KFSlideMenuOverlayView *overlayView;
@end

@implementation KFSlideMenuViewController
@synthesize menuView = _menuView;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
	if (self = [super init])
	{
		self->_rootViewController = rootViewController;
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
		
	self.overlayView = [[KFSlideMenuOverlayView alloc] initWithSuperview:self.view];
	self.overlayView.delegate = self;
	self.overlayView.topView = self.menuView;
	[self.view addSubview:self.overlayView];
	
	[self showMenu:NO animated:NO];
}

#pragma mark - Properties

- (void)setRootViewController:(UIViewController *)rootViewController
{
	if (!rootViewController)
		return;

	if (self->_rootViewController)
	{
		[self->_rootViewController.view removeFromSuperview];
		[self->_rootViewController removeFromParentViewController];
	}
	
	self->_rootViewController = rootViewController;
	[self addChildViewController:rootViewController];
	
	[self.view insertSubview:rootViewController.view belowSubview:self.overlayView];
}

- (void)setMenuView:(UIView *)menuView
{
	self->_menuView = menuView;
	self.overlayView.topView = menuView;
}

- (UIView *)menuView
{
	return self->_menuView;
}

#pragma mark -

- (void)showMenu:(BOOL)show animated:(BOOL)animated
{
	CGFloat percent = show ? 1.f : 0.f;
	[self setOverlayPercent:percent animated:animated];
	
	self->_isOpened = show;
}

#pragma mark - Helpers

- (void)setOverlayPercent:(CGFloat)percent animated:(BOOL)animated
{
	if (!animated)
	{
		self.overlayView.percent = percent;
	} else {
		CGFloat target = (percent == 0) ? .01f : percent;
		NSTimeInterval duration = .275 * ABS(percent - self.overlayView.percent);
		[UIView animateWithDuration:duration animations:^{
			self.overlayView.percent = target;
		} completion:^(BOOL finished) {
			self.overlayView.percent = percent;
		}];
	}
//	static NSString * const kAnimationKey = @"percent";
//	static NSString * const kAnimationName = @"com.kf.slidemenu.overlay.percent";
//	
//	if (!animated)
//	{
//		[self.overlayView pop_removeAnimationForKey:kAnimationKey];
//		self.overlayView.percent = percent;
//		return;
//	}
//	
//	POPSpringAnimation *anim = [POPSpringAnimation animation];
//	anim.property = [POPAnimatableProperty propertyWithName:kAnimationName initializer:^(POPMutableAnimatableProperty *prop) {
//		prop.readBlock = ^(KFSlideMenuOverlayView *obj, CGFloat values[]) {
//			values[0] = [obj percent];
//		};
//		prop.writeBlock = ^(KFSlideMenuOverlayView *obj, const CGFloat values[]) {
//			obj.percent = values[0];
//		};
//		prop.threshold = 0.01;
//	}];
//	
//	anim.toValue = @(percent);
//	[self.overlayView pop_addAnimation:anim forKey:kAnimationKey];
}

#pragma mark - KFSlideMenuOverlayViewDelegate

- (void)slideMenuOverlayView:(KFSlideMenuOverlayView *)overlayView tapGesture:(UIGestureRecognizer *)gesture
{
	[self showMenu:!self.isOpened animated:YES];
}

- (void)slideMenuOverlayView:(KFSlideMenuOverlayView *)overlayView panGesture:(UIPanGestureRecognizer *)gesture
{
	DASSERT([gesture isKindOfClass:[UIPanGestureRecognizer class]]);
	
	switch (gesture.state)
	{
		case UIGestureRecognizerStateBegan:
			self->_overlayPercent = self.overlayView.percent;
			break;
			
		case UIGestureRecognizerStateChanged: {
			CGPoint translation = [gesture translationInView:gesture.view];
			CGFloat width = CGRectGetWidth(self.overlayView.topView.frame);
			CGFloat percent = MAX(0, MIN((width + translation.x), width)) / width;
			[self setOverlayPercent:percent animated:NO];
		} break;
		
		case UIGestureRecognizerStateEnded: {
			BOOL show = self.isOpened;
			CGFloat dt = self->_overlayPercent - self.overlayView.percent;
			if (fabs(dt) > kSlideMenuPanTresholdPercent) {
				show = (dt < 0);
			}
			
			[self showMenu:show animated:YES];
		} break;

		case UIGestureRecognizerStateFailed:
			[self showMenu:self.isOpened animated:YES];
			break;
			
		default:
			break;
	}
}

@end
