//
//  NSDate+CPUtils.m
//  CityParking
//
//  Created by Igor Zubko on 21.12.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "NSDate+CPUtils.h"
#import <DateTools/NSDate+DateTools.h>

@implementation NSDate (CPUtils)

- (NSDate *)cp_roundToNextMinutes:(NSUInteger)minutes
{
	NSInteger min = (self.minute/(minutes + 1) + 1) * minutes;
	
	return [NSDate dateWithYear:self.year month:self.month day:self.day hour:self.hour minute:min second:0];
}

@end
