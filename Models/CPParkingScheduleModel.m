//
//  CPParingScheduleModel.m
//  CityParking
//
//  Created by Igor Zubko on 26.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPParkingScheduleModel.h"
#import "NSArray+CPUtils.h"
#import <DateTools/DateTools.h>

@interface CPParkingScheduleModel ()
{
	char _workingDays;
}
@property (nonatomic, retain) NSString *timeString;
@property (nonatomic, retain) NSString *daysString;
@end

@implementation CPParkingScheduleModel

+ (instancetype)scheduleWithStartTime:(NSDate *)startTime endTime:(NSDate *)endTime andDaysHash:(char)daysHash
{
	CPParkingScheduleModel *model = [CPParkingScheduleModel new];
	[model setTimeStart:startTime andEnd:endTime];
	[model setDaysHash:daysHash];
	return model;
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
	NSDictionary *properties = @{
		@"timeString": @"time",
		@"daysString": @"days"
	};
	
	return properties;
}

#pragma mark - Properties

- (void)setTimeStart:(NSDate *)timeStart andEnd:(NSDate *)timeEnd
{
	NSDateFormatter *timeFormat = [NSDateFormatter new];
	timeFormat.dateFormat = @"HH:mm";
	
	NSString *timeString = [NSString stringWithFormat:@"%@-%@", [timeFormat stringFromDate:timeStart], [timeFormat stringFromDate:timeEnd]];
	[self setTimeString:timeString];
}

- (void)setDaysHash:(char)daysHash
{
	NSDictionary *daysMap = [self daysMapReverse];
	NSMutableArray *daysArray = [NSMutableArray arrayWithCapacity:7];
	
	for (NSInteger i = CPParingScheduleDayMonday; i <= CPParingScheduleDaySunday; i++) {
		if ((daysHash & (1 << i)) != 0) {
			[daysArray addObject:daysMap[@(i)]];
		}
	}
	
	NSString *daysString = [daysArray componentsJoinedByString:@","];
	[self setDaysString:daysString];
}

- (void)setDaysString:(NSString *)daysString
{
	_daysString = daysString;
	
	static NSDictionary *daysMap;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		daysMap  = @{
			@"mon": @(CPParingScheduleDayMonday),
			@"tue": @(CPParingScheduleDayTuesday),
			@"wed": @(CPParingScheduleDayWednesday),
			@"thu": @(CPParingScheduleDayThursday),
			@"fri": @(CPParingScheduleDayFriday),
			@"sat": @(CPParingScheduleDaySaturday),
			@"sun": @(CPParingScheduleDaySunday),
			
			@"monday":    @(CPParingScheduleDayMonday),
			@"tuesday":   @(CPParingScheduleDayTuesday),
			@"wednesday": @(CPParingScheduleDayWednesday),
			@"thursday":  @(CPParingScheduleDayThursday),
			@"friday":    @(CPParingScheduleDayFriday),
			@"saturday":  @(CPParingScheduleDaySaturday),
			@"sunday":    @(CPParingScheduleDaySunday),
		};
	});
	
	// split string to days array
	NSArray<NSString *> *daysArray = [[daysString componentsSeparatedByString:@","] cp_map:^id(NSString *str) {
		return [str.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	}];
	
	// clear old data structure
	self->_workingDays = 0;
	
	// fill data structure with new data
	for (NSString *day in daysArray)
	{
		NSNumber *index = daysMap[day];
		if (index != nil) {
			self->_workingDays |= 1 << index.intValue;
		}
	}
}

- (void)setTimeString:(NSString *)timeString
{
	_timeString = timeString;
	
	NSDateFormatter *timeFormat = [NSDateFormatter new];
	timeFormat.dateFormat = @"HH:mm";
	
	NSArray<NSDate *> *times = [[timeString componentsSeparatedByString:@"-"] cp_map:^NSDate *(NSString *str) {
		str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		return [timeFormat dateFromString:str];
	}];
	
	if (times.count == 2)
	{
		self->_timeStart = times[0];
		self->_timeEnd = times[1];
	}
}

#pragma mark - Public

- (char)daysHash
{
	return  self->_workingDays;
}

- (BOOL)isAvailableAtDay:(CPParingScheduleDay)day
{
	DASSERT(day >= 0 && day <= CPParingScheduleDaySunday);
	
	return (self->_workingDays & (1 << day)) != 0;
}

- (NSString *)daysDescription
{
	static NSDictionary *daysMap;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		daysMap  = @{
			@(CPParingScheduleDayMonday): @"Mon",
			@(CPParingScheduleDayTuesday): @"Tue",
			@(CPParingScheduleDayWednesday): @"Wed",
			@(CPParingScheduleDayThursday): @"Thu",
			@(CPParingScheduleDayFriday): @"Fri",
			@(CPParingScheduleDaySaturday): @"Sat",
			@(CPParingScheduleDaySunday): @"Sun"
		};
	});

	NSMutableArray *daysArr = [NSMutableArray arrayWithCapacity:7];
	for (NSInteger i=0; i < 7; i++) {
		if ([self isAvailableAtDay:i]) {
			[daysArr addObject:daysMap[@(i)]];
		}
	}
	
	return [daysArr componentsJoinedByString:@", "];
}

- (NSString *)timeDescription
{
	// check if interval between timeStart and endTime equal (at least) 23h59m
	CGFloat d = [self.timeEnd minutesFrom:self.timeStart];
	
	if (d >= 1439 && self.daysHash == 127) {
		return @"All day";
	}
	
	return [NSString stringWithFormat:@"%@ - %@", [self.timeStart formattedDateWithFormat:@"hh:mma"].lowercaseString, [self.timeEnd formattedDateWithFormat:@"hh:mma"].lowercaseString];
}

- (NSDate *)nextAvailableTimeAfter:(NSDate *)date
{
	if (date == nil) {
		return nil;
	}

	if (self->_workingDays == 127) {
		return date;
	}

	NSInteger min = date.hour * 60 + date.minute;

	NSInteger minStart = self.timeStart.hour * 60 + self.timeStart.minute;
	NSInteger minEnd = self.timeEnd.hour * 60 + self.timeEnd.minute;

	for (NSInteger i = 0; i < 7; i++)
	{
		NSInteger n = (self->_workingDays & (1 << (i % 7)));

		if (n != 0)
		{
			if (min >= minStart && min < minEnd)
			{
				return [NSDate dateWithYear:date.year
									  month:date.month
										day:date.day + i
									   hour:self.timeStart.hour
									 minute:self.timeStart.minute
									 second:0];
			} else if ((self->_workingDays & (1 << ((i + 1) % 7))) != 0) {
				return [NSDate dateWithYear:date.year
									  month:date.month
										day:date.day + i + 1
									   hour:self.timeStart.hour
									 minute:self.timeStart.minute
									 second:0];
			}
		}
	}

	return nil;
}

- (NSDictionary *)daysMap
{
	static NSDictionary *daysMap;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		daysMap  = @{
			@"mon": @(CPParingScheduleDayMonday),
			@"tue": @(CPParingScheduleDayTuesday),
			@"wed": @(CPParingScheduleDayWednesday),
			@"thu": @(CPParingScheduleDayThursday),
			@"fri": @(CPParingScheduleDayFriday),
			@"sat": @(CPParingScheduleDaySaturday),
			@"sun": @(CPParingScheduleDaySunday),
		};
	});

	return daysMap;
}

- (NSDictionary *)daysMapReverse
{
	static NSDictionary *daysMapReverse;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSDictionary *daysMap = [self daysMap];
		NSMutableDictionary *rev = [NSMutableDictionary dictionaryWithCapacity:daysMap.count];
		
		[daysMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			rev[obj] = key;
		}];
		
		daysMapReverse = [NSDictionary dictionaryWithDictionary:rev];
	});
	
	return daysMapReverse;
}

@end
