//
//  UIView+CPUtils.h
//  CityParking
//
//  Created by Igor Zubko on 17.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CPUtils)

- (void)scrollToY:(CGFloat)y;
- (void)scrollToView:(UIView *)view;
- (void)scrollElement:(UIView *)view toPoint:(CGFloat)y;

@end
