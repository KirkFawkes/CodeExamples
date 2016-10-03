//
//  CPPaidParkingInfo.m
//  CityParking
//
//  Created by Igor Zubko on 04.12.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPPaidParkingInfo.h"
#import "NSArray+CPUtils.h"
#import <MapKit/MKGeometry.h>

@implementation CPPaidParkingInfo
@synthesize bookingId = _bookingId;

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
	NSDictionary *properties = @{
		@"address1": @"address1",
		@"address2": @"address2",
		@"photoUrl": @"image_path",
		@"price": @"price",
		@"distance": @"distance",
		@"location": @"location",
		@"schedule": @"schedule",
		@"bookingId": @"my_booking_id",
		@"bookingList": @"booked",
		@"isAvailable": @"status",
		@"spotDescription": @"description",
		@"currentStatus": @"period_availability_status",
		@"currentStatusDate": @"period_availability_date",
		@"nearestBooking": @"nearest_booking"
	};
	
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:properties];
}

+ (NSValueTransformer *)photoUrlJSONTransformer
{
	return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError **error) {
		if (value.length == 0) {
			return nil;
		}
		
		if ([value hasPrefix:@"http://"] || [value hasPrefix:@"https://"]) {
			return [NSURL URLWithString:value];
		}
		
		NSString *fullPath = [CPConfigServerUploadBaseUrl stringByAppendingFormat:@"/%@", value];
		return [NSURL URLWithString:fullPath];
	} reverseBlock:^id(id value, BOOL *success, NSError **error) {
		return [NSString stringWithFormat:@"%@", value];
	}];
}

+ (NSValueTransformer *)bookedJSONTransformer
{
	return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
		return @(ExtractBolean(value));
	} reverseBlock:^id(id value, BOOL *success, NSError **error) {
		return [NSString stringWithFormat:@"%@", value];
	}];
}

+ (NSValueTransformer *)priceJSONTransformer
{
	return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
		DASSERT([ExtractNumber(value) isKindOfClass:[NSNumber class]]);
		return ExtractNumber(value);
	} reverseBlock:^id(id value, BOOL *success, NSError **error) {
		return [NSString stringWithFormat:@"%@", value];
	}];
}

+ (NSValueTransformer *)distanceJSONTransformer
{
	return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
		DASSERT([ExtractNumber(value) isKindOfClass:[NSNumber class]]);
		return ExtractNumber(value);
	} reverseBlock:^id(id value, BOOL *success, NSError **error) {
		return [NSString stringWithFormat:@"%@", value];
	}];
}

+ (NSValueTransformer *)locationJSONTransformer
{
	return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *locationDict, BOOL *success, NSError **error) {
		CLLocationDegrees latitude = [locationDict[@"latitude"] doubleValue];
		CLLocationDegrees longitude = [locationDict[@"longitude"] doubleValue];
		return [NSValue valueWithMKCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
	} reverseBlock:^id(CLLocation *location, BOOL *success, NSError **error) {
		return @{@"latitude": @(location.coordinate.latitude), @"longitude": @(location.coordinate.longitude)};
	}];
}

+ (NSValueTransformer *)scheduleJSONTransformer
{
	return [MTLJSONAdapter arrayTransformerWithModelClass:CPParkingScheduleModel.class];
}

+ (NSValueTransformer *)bookingListJSONTransformer
{
	return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray<NSDictionary *> *list, BOOL *success, NSError **error) {
		return [list cp_map:^id(NSDictionary *item) {
			NSDate *to = NSStringToDateFull(item[@"to"]);
			NSDate *from = NSStringToDateFull(item[@"from"]);
			
			return [DTTimePeriod timePeriodWithStartDate:from endDate:to];
		}];
	} reverseBlock:^id(NSArray<DTTimePeriod *> *value, BOOL *success, NSError **error) {
		return [value cp_map:^id(DTTimePeriod *item) {
			return @{
				@"from": NSDateToStringFull(item.StartDate),
				@"to": NSDateToStringFull(item.EndDate),
			};
		}];
	}];
}

+ (NSValueTransformer *)isAvailableJSONTransformer
{
	return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *str, BOOL *success, NSError **error) {
		return @([str isEqualToString:@"available"]);
	} reverseBlock:^id(NSNumber *value, BOOL *success, NSError **error) {
		return (value.boolValue) ? @"available" : @"unavailable";
	}];
}

+ (NSValueTransformer *)currentStatusJSONTransformer
{
	return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *str, BOOL *success, NSError **error) {
		if ([str isEqualToString:@"not_available"]) {
			return @(CPPaidParkingInfoCurrentStatusUnavailable);
		}

		if ([str isEqualToString:@"partial_available"]) {
			return @(CPPaidParkingInfoCurrentStatusOccupied);
		}

		return @(CPPaidParkingInfoCurrentStatusAvailable);
		
		return @([str isEqualToString:@"available"]); // -- wtf?!
	}];
}

+ (NSValueTransformer *)currentStatusDateJSONTransformer
{
	return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *str, BOOL *success, NSError **error) {
		return NSStringToDateFull(str);
	}];
}

#pragma mark - Helpers

- (NSString *)timeFormatForDate:(NSDate *)date
{
	NSInteger days = [date daysUntil];
	
	if ([date dayOfYear] == [[NSDate date] dayOfYear]) {
		return @"h:mm a";
	} else if (days < 7) {
		return @"EEEE h:mm a";
	} else {
		return @"d MMMM h:mm a";
	}
}

#pragma mark -

- (BOOL)isBooked
{
	return self.bookingId != nil;
}

- (void)setIsBooked:(CPObjectModelId)bookingId
{
	if ([bookingId isKindOfClass:[NSString class]]) {
		self->_bookingId = bookingId;
	} else {
		self->_bookingId = [bookingId description];
	}
}

- (NSString *)statusText
{
	NSString *status = @"";
	
	switch (self.currentStatus)
	{
		case CPPaidParkingInfoCurrentStatusUnknown:
		case CPPaidParkingInfoCurrentStatusAvailable:
			status = NSLocalizedString(@"Available", Nil);
			break;
			
		case CPPaidParkingInfoCurrentStatusUnavailable:
			status = NSLocalizedString(@"Unavailable", Nil);
			break;
			
		case CPPaidParkingInfoCurrentStatusOccupied:
			status = NSLocalizedString(@"Occupied", Nil);
			break;
			
		default:
			break;
	}
	
	if (status.length > 0 && self.currentStatusDate != nil)
	{
        NSString *timeString = [self.currentStatusDate formattedDateWithFormat:[self timeFormatForDate:self.currentStatusDate]];
		status = [status stringByAppendingFormat:@" until %@", timeString];
	}
	
	return status;

//	NSDate *currentDate = [NSDate date];
//	NSDate *date = [currentDate dateByAddingMinutes:15];
//	NSArray<DTTimePeriod *> *bookedPeriods = [[self.bookingList cp_filter:^BOOL(DTTimePeriod *item) {
//		return [date compare:item.StartDate] == NSOrderedAscending || [date compare:item.EndDate] == NSOrderedAscending;
//	}] sortedArrayUsingComparator:^NSComparisonResult(DTTimePeriod *obj1, DTTimePeriod *obj2) {
//		return [obj1.StartDate compare:obj2.StartDate];
//	}];
//	
//	// Check for Occupied
//	DTTimePeriod *firstPeriod = [bookedPeriods firstObject];
//	if ([firstPeriod containsDate:date interval:DTTimePeriodIntervalClosed])
//	{
//		self.status = CPParkingInfoAvailableStatusOccupied;
//		NSString *timeString = [firstPeriod.EndDate formattedDateWithFormat:[self timeFormatForDate:firstPeriod.EndDate]];
//		return [NSString stringWithFormat:@"Occupied untill %@", timeString];
//	}
//	// Check fo available
//	NSDate *availableDate = [[[self.schedule cp_map:^id(CPParkingScheduleModel *item) {
//		return [item nextAvailableTimeAfter:currentDate];
//	}] sortedArrayUsingComparator:^NSComparisonResult(NSDate *obj1, NSDate *obj2) {
//		return [obj1 compare:obj2];
//	}] firstObject];
//	
//	if (availableDate == nil) {
//		self.status = CPParkingInfoAvailableStatusUnavailable;
//		return @"Unavailable";
//	} else if ([availableDate isEqual:currentDate]) {
//		self.status = CPParkingInfoAvailableStatusAvailable;
//		return @"Available";
//	} else if ([availableDate compare:currentDate] == NSOrderedAscending) {
//		self.status = CPParkingInfoAvailableStatusAvailable;
//		NSString *timeString = [availableDate formattedDateWithFormat:[self timeFormatForDate:availableDate]];
//		return [NSString stringWithFormat:@"Available till %@", timeString];
//	} else {
//		self.status = CPParkingInfoAvailableStatusUnavailable;
//		NSString *timeString = [availableDate formattedDateWithFormat:[self timeFormatForDate:availableDate]];
//		return [NSString stringWithFormat:@"Unavailable untill %@", timeString];
//	}
//	return nil;
}

- (UIColor *)statusColor
{
	// Force status update
	[self statusText];
	
	UIColor *color = nil;
	
	if (self.currentStatus != CPPaidParkingInfoCurrentStatusUnknown)
	{
		switch (self.currentStatus)
		{
			case CPPaidParkingInfoCurrentStatusAvailable:
				color = RGBCOLOR(77, 216, 101);		// Green
				break;
				
			case CPPaidParkingInfoCurrentStatusUnavailable:
				color = RGBCOLOR(193, 198, 201);	// Gray
				break;
				
			case CPPaidParkingInfoCurrentStatusOccupied:
				color = RGBCOLOR(247, 109, 109);	// Red
				break;
				
			default:
				break;
		}
	} else {
		switch (self.status)
		{
			case CPParkingInfoAvailableStatusUnknown:
			case CPParkingInfoAvailableStatusUnavailable:
				color = RGBCOLOR(193, 198, 201);	// Gray
				break;
			case CPParkingInfoAvailableStatusOccupied:
				color = RGBCOLOR(247, 109, 109);	// Red
				break;
			case CPParkingInfoAvailableStatusAvailable:
				color = RGBCOLOR(77, 216, 101);		// Green
				break;
			default:
				[NSException raise:@"Unknown status" format:@""];
				break;
		}
	}
	
	return color;
}

- (NSString *)fullAddress
{
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:2];
	if (self.address1.length > 0) {
		[arr addObject:self.address1];
	}
	
	if (self.address2.length > 0) {
		[arr addObject:self.address2];
	}
	
	return [arr componentsJoinedByString:@", "];
}

@end
