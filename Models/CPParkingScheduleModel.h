//
//  CPParingScheduleModel.h
//  CityParking
//
//  Created by Igor Zubko on 26.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPObjectModel.h"
#import <Mantle/Mantle.h>

typedef enum : NSUInteger {
	CPParingScheduleDayMonday = 0,
	CPParingScheduleDayTuesday,
	CPParingScheduleDayWednesday,
	CPParingScheduleDayThursday,
	CPParingScheduleDayFriday,
	CPParingScheduleDaySaturday,
	CPParingScheduleDaySunday,
} CPParingScheduleDay;

@interface CPParkingScheduleModel : CPObjectModel<MTLJSONSerializing>
@property (nonatomic, readonly) char daysHash;

@property (nonatomic, readonly) NSDate *timeStart;
@property (nonatomic, readonly) NSDate *timeEnd;

@property (nonatomic, assign) NSUInteger tag;

- (BOOL)isAvailableAtDay:(CPParingScheduleDay)day;

- (NSString *)daysDescription;
- (NSString *)timeDescription;

- (NSDate *)nextAvailableTimeAfter:(NSDate *)date;

+ (instancetype)scheduleWithStartTime:(NSDate *)startTime endTime:(NSDate *)endTime andDaysHash:(char)daysHash;

@end
