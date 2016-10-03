//
//  KFSlideMenuOverlayView.m
//  CityParking
//
//  Created by Igor on 23.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import "KFSlideMenuOverlayView.h"

inline static BOOL isFloatEqual(CGFloat a, CGFloat b) {
	return fabs(a - b) < FLT_EPSILON;
}

@interface KFSlideMenuOverlayView () <UIGestureRecognizerDelegate>
{
	CGFloat _percent;
	UITapGestureRecognizer *_tapGesture;
	UIPanGestureRecognizer *_panGesture;
}
@property (nonatomic, retain) UIView *overlay;
@end

@implementation KFSlideMenuOverlayView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	[self _initialize];
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	[self _initialize];
	return self;
}

- (instancetype)initWithSuperview:(UIView *)view
{
	if (self = [super init])
	{
		self.topView = view;
	}
	
	return self;
}

- (void)_initialize
{
	self->_percent = 0.f;
	
	self->_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
	self->_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
	self->_panGesture.delegate = self;
	
	self.overlayColor = [UIColor colorWithWhite:.0 alpha:.5];
	self->_overlay = [[UIView alloc] initWithFrame:self.bounds];
	self->_overlay.backgroundColor = self.overlayColor;
	[self->_overlay addGestureRecognizer:self->_tapGesture];
	[self addSubview:self->_overlay];
	
	self.autoresizesSubviews = NO;
	self.clipsToBounds = YES;
	
	[self addGestureRecognizer:self->_panGesture];
	[super setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Layout updates

- (void)resizeView
{
	[self setNeedsLayout];
	[self layoutIfNeeded];
	
	self.percent = self->_percent;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	self.frame = self.superview.bounds;
}

- (void)setPercent:(CGFloat)percent
{
	self->_percent = percent;
	
	const CGFloat menuWidth = CGRectGetWidth(self.topView.frame);
	const CGFloat menuX = -menuWidth * (1.f - percent) - 4;
	
	self.frame = self.superview.bounds;

	self.topView.frame = CGRectMake(menuX, 0, menuWidth, CGRectGetHeight(self.frame));
	self.overlay.frame = CGRectMake(menuX + menuWidth, 0, CGRectGetWidth(self.frame) - (menuX + menuWidth), CGRectGetHeight(self.frame));
	
	self.backgroundColor = [self overlayColorWithPercent:percent];
}

#pragma mark - Helpers

- (UIColor *)overlayColorWithPercent:(CGFloat)percent
{
	UIColor *color = self.overlayColor;
	
	const CGFloat colorAlpha = CGColorGetAlpha(color.CGColor);
	const CGFloat mult = MAX(MIN(percent, 1.f), 0);
	const CGFloat alpha = colorAlpha * mult;
	
	return [color colorWithAlphaComponent:alpha];
}

#pragma mark - Properties

- (void)setTopView:(UIView *)topView
{
	[self->_topView removeFromSuperview];
	
	[self addSubview:topView];
	self->_topView = topView;
	
	[self bringSubviewToFront:self->_overlay];
	[self setNeedsLayout];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
	self->_overlay.backgroundColor = backgroundColor;

	self.hidden = isFloatEqual(CGColorGetAlpha(backgroundColor.CGColor), 0.f);
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if (gestureRecognizer != self->_panGesture)
		return YES;
	
	const CGPoint point = [touch locationInView:self];
	const CGFloat width = CGRectGetMaxX(self.topView.frame);
	
	return point.x > (width * 0.50);
}

#pragma mark - Gestures handlers

- (void)panGesture:(UIPanGestureRecognizer *)gesture
{
	if ([self.delegate respondsToSelector:@selector(slideMenuOverlayView:panGesture:)])
		[self.delegate slideMenuOverlayView:self panGesture:gesture];
}

- (void)tapGesture:(UIPanGestureRecognizer *)gesture
{
	if ([self.delegate respondsToSelector:@selector(slideMenuOverlayView:tapGesture:)])
		[self.delegate slideMenuOverlayView:self tapGesture:gesture];
}

@end
