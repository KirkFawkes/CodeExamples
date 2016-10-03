//
//  UIImage+CPUtils.h
//  CityParking
//
//  Created by Igor Zubko on 27.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CPUtils)

+ (UIImage *)cp_imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)cp_imageWithImage:(UIImage *)image scaledToFitSize:(CGSize)newSize;

@end
