//
//  KFSlideMenuOverlayView.h
//  CityParking
//
//  Created by Igor on 23.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KFSlideMenuOverlayView;

@protocol KFSlideMenuOverlayViewDelegate <NSObject>
@optional
- (void)slideMenuOverlayView:(KFSlideMenuOverlayView *)overlayView tapGesture:(UIGestureRecognizer *)gesture;
- (void)slideMenuOverlayView:(KFSlideMenuOverlayView *)overlayView panGesture:(UIGestureRecognizer *)gesture;
@end

@interface KFSlideMenuOverlayView : UIView
@property (nonatomic, retain) UIView *topView;
@property (nonatomic, retain) UIColor *overlayColor;
@property (nonatomic, assign) CGFloat percent;
@property (nonatomic, weak) id<KFSlideMenuOverlayViewDelegate> delegate;

- (instancetype)initWithSuperview:(UIView *)view;

- (void)resizeView;

@end
