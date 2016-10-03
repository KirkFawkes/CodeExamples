//
//  CPTimeSelctionViewController.m
//  CityParking
//
//  Created by Igor Zubko on 25.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPTimePickerViewController.h"

@interface CPTimePickerViewController () <UIViewControllerTransitioningDelegate>
{
	NSDate *_date;
	NSDate *_minDate;
}
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIDatePicker *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@end

@interface CPTimePickerViewControllerTransitioning : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic) BOOL presenting;
@end

@implementation CPTimePickerViewControllerTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
	return .25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
	// params
	const CGFloat animationDuration = .25;
	UIColor * const backgroundColorInitial = [UIColor clearColor];
	UIColor * const backgroundColorPresented = [UIColor colorWithWhite:0.f alpha:.5f];
	
	UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIView *container = transitionContext.containerView;
	
	
	if (self.presenting)
	{
		DASSERT([toViewController isKindOfClass:[CPTimePickerViewController class]]);
		
		CPTimePickerViewController *vc = (CPTimePickerViewController *)toViewController;
		
		[container addSubview:vc.view];
		
		vc.view.frame = fromViewController.view.bounds;
		vc.backgroundView.frame = CGRectMake(0, CGRectGetHeight(vc.view.bounds), CGRectGetWidth(vc.backgroundView.frame),
											 CGRectGetHeight(vc.backgroundView.frame));
		vc.view.backgroundColor = backgroundColorInitial;
		[UIView animateWithDuration:animationDuration animations:^{
			vc.view.backgroundColor = backgroundColorPresented;
			vc.backgroundView.frame = CGRectMake(0, CGRectGetHeight(vc.view.bounds)-CGRectGetHeight(vc.backgroundView.frame),
												 CGRectGetWidth(vc.backgroundView.frame), CGRectGetHeight(vc.backgroundView.frame));
		} completion:^(BOOL finished) {
			[transitionContext completeTransition:YES];
		}];
	} else {
		DASSERT([fromViewController isKindOfClass:[CPTimePickerViewController class]]);
		
		CPTimePickerViewController *vc = (CPTimePickerViewController *)fromViewController;
		[UIView animateWithDuration:animationDuration animations:^{
			vc.view.backgroundColor = backgroundColorInitial;
			vc.backgroundView.frame = CGRectMake(0, CGRectGetHeight(vc.view.bounds), CGRectGetWidth(vc.backgroundView.frame),
												 CGRectGetHeight(vc.backgroundView.frame));
		} completion:^(BOOL finished) {
			[vc.view removeFromSuperview];
			[transitionContext completeTransition:YES];
		}];
	}
}
@end

@implementation CPTimePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.modalInPopover = YES;
	self.modalPresentationStyle = UIModalPresentationCustom;
	
	self.transitioningDelegate = self;
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView:)];
	[self.view addGestureRecognizer:tapGesture];
	
	UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeView:)];
	swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
	[self.view addGestureRecognizer:swipeGesture];
	
	[self.pickerView addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
	
	self.pickerView.date = self->_date;
	self.pickerView.minimumDate = self->_minDate;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if ([self.delegate respondsToSelector:@selector(timePicker:viewWillDisappear:)]) {
		[self.delegate timePicker:self viewWillDisappear:animated];
	}
}

#pragma mark - Properties

- (void)setMinDate:(NSDate *)minDate
{
	self->_minDate = minDate;
}

- (NSDate *)minDate
{
	return self.pickerView.minimumDate;
}

- (void)setDate:(NSDate *)date
{
	self->_date = date;
	
	self.pickerView.date = date;
}

- (NSDate *)date
{
	return self.pickerView.date;
}

#pragma mark - Helpers

- (IBAction)closeView:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notifications

- (void)pickerChanged:(id)sender
{
	if ([self.delegate respondsToSelector:@selector(timePicker:didChangedDate:)]) {
		[self.delegate timePicker:self didChangedDate:self.pickerView.date];
	}
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
	CPTimePickerViewControllerTransitioning *transitioning = [CPTimePickerViewControllerTransitioning new];
	transitioning.presenting = YES;
	return transitioning;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
	CPTimePickerViewControllerTransitioning *transitioning = [CPTimePickerViewControllerTransitioning new];
	transitioning.presenting = NO;
	return transitioning;
}

@end
