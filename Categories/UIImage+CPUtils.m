//
//  UIImage+CPUtils.m
//  CityParking
//
//  Created by Igor Zubko on 27.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "UIImage+CPUtils.h"

@implementation UIImage (CPUtils)

+ (UIImage *)cp_imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
	UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
	[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

+ (UIImage *)cp_imageWithImage:(UIImage *)image scaledToFitSize:(CGSize)newSize
{
	CGFloat k = image.size.width / newSize.width;
	return [self cp_imageWithImage:image scaledToSize:CGSizeMake(newSize.width, newSize.height / k)];
}

@end
