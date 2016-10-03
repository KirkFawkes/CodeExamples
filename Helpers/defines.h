//
//  defines.h
//  CityParking
//
//  Created by Igor on 19.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#ifndef CityParking_defines_h
#define CityParking_defines_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <NSDate+DateTools.h>
#import "constants.h"

static inline int RND(int min, int max) {
	return (arc4random()%(max - min)) + min;
}

#pragma mark - Colors

static inline UIColor * RGBACOLOR(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
	return [UIColor colorWithRed:(red/255.f) green:(green/255.f) blue:(blue/255.f) alpha:alpha];
}

static inline UIColor * RGBCOLOR(CGFloat red, CGFloat green, CGFloat blue) {
	return RGBACOLOR(red, green, blue, 1.f);
}

static inline UIColor * RGBCOLORHEX(NSUInteger rgbValue) {
	CGFloat red =   (rgbValue & 0xFF0000) >> 16;
	CGFloat green = (rgbValue & 0x00FF00) >> 8;
	CGFloat blue =  (rgbValue & 0x0000FF);
	
	return RGBCOLOR(red, green, blue);
}

static inline UIColor * RNDCOLOR() {
	return RGBCOLOR(RND(0, 255), RND(0, 255), RND(0, 255));
}

#pragma mark - Date

static inline NSString * NSDateToStringFull(NSDate *date) {
//	return [date formattedDateWithFormat:@"YYYY-MM-dd HH:mm:ss" timeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	return [date formattedDateWithFormat:@"YYYY-MM-dd HH:mm:ss"];
}

static inline NSDate * NSStringToDateFull(NSString *value) {
	if (value.length == 0) {
		return nil;
	}
	
//	NSDate *dateInUTC = [NSDate dateWithString:value formatString:@"YYYY-MM-dd HH:mm:ss" timeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
//	NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
//	NSDate *dateInLocalTimezone = [dateInUTC dateByAddingTimeInterval:timeZoneSeconds];
//	return dateInLocalTimezone;
	return [NSDate dateWithString:value formatString:@"YYYY-MM-dd HH:mm:ss"];
}

#pragma mark - Time

static inline NSString * NSStringFromTimeShort(NSDate *date) {
//	return [date formattedDateWithFormat:@"HH:mm" timeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	return [date formattedDateWithFormat:@"HH:mm"];
}

static inline NSDate * NSTimeFromShortString(NSString *value) {
	if (value.length == 0) {
		return nil;
	}
	
//	NSDate *dateInUTC = [NSDate dateWithString:value formatString:@"HH:mm" timeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
//	NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
//	NSDate *dateInLocalTimezone = [dateInUTC dateByAddingTimeInterval:timeZoneSeconds];
//	return dateInLocalTimezone;
	
	return [NSDate dateWithString:value formatString:@"HH:mm"];
}

//static inline NSDate * NSUTCDateFromDate(NSDate *date) {
//	NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
//	return [date dateByAddingTimeInterval:-timeZoneSeconds];
//}

#pragma mark - Others

inline static NSString *NSStringFromCLLocationCoordinate2D(const CLLocationCoordinate2D location) {
	return [NSString stringWithFormat:@"%lf,%lf", location.latitude, location.longitude];
}

inline static NSError *NSParsingErrorMake(NSDictionary *params) {
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:params];
	userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Parsing error", nil);
	return [NSError errorWithDomain:@"com.cityparking.errors" code:kCPErrorCodeDataParsingError userInfo:userInfo];
}

inline static void CPDispatchAfter(CGFloat time, dispatch_block_t block) {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time* NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

inline static NSError *CPErrorMake(NSInteger code, NSString *localizedDescription) {
	NSDictionary *userInfo = (localizedDescription.length > 0) ? @{NSLocalizedDescriptionKey: localizedDescription} : nil;
	return [NSError errorWithDomain:kErrorApplicationDomain code:code userInfo:userInfo];
}

#define CPSafeCallBlock(block, ...) do { if (block) block(__VA_ARGS__); } while(0)

#define STRING_FROM_RECT(rect) NSStringFromCGRect(rect)

#define UIViewAutoresizingAll (UIViewAutoresizingNone | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin)

typedef void (^CPServiceSuccessBlock)(id result);
typedef void (^CPServiceErrorBlock)(NSError *error);

#define DEPRECATED_METHOD __attribute__ ((deprecated))
#define DEPRECATED_METHOD_MSG(msg) __attribute__ ((deprecated(msg)))


#endif
