//
//  CPParkingService.m
//  CityParking
//
//  Created by Igor Zubko on 20.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPParkingService.h"
// Services
#import "CPNetworkService.h"
// Models
#import "CPParkingInfo.h"
#import "CPBookingInfoModel.h"
// Other
#import "constants.h"
#import "defines.h"
//
#import <DateTools/DateTools.h>
// Categories
#import "NSData+NSInputStream.h"
#import "NSArray+CPUtils.h"

NSMutableSet *CPParkingServiceFavoritesMock;

NSString *kParkingServiceParkingUpdated = @"com.cp.parking.updated";

// TODO: remove this later
static inline NSString *CPParkingScheduleModelToString(NSArray<CPParkingScheduleModel *> *schedules) {
//	const NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
//	
//	NSArray *schedulesIntGlobalTimezone = [schedules cp_map:^id(CPParkingScheduleModel *item) {
//		NSDate *startTime = [item.timeStart dateByAddingTimeInterval:-timeZoneSeconds];
//		NSDate *endTime = [item.timeEnd dateByAddingTimeInterval:-timeZoneSeconds];
//		
//		return [CPParkingScheduleModel scheduleWithStartTime:startTime endTime:endTime andDaysHash:item.daysHash];
//	}];
	
	return [[NSJSONSerialization dataWithJSONObject:[MTLJSONAdapter JSONArrayFromModels:schedules error:nil] options:0 error:nil] toString];
}

@implementation CPParkingService

- (instancetype)init
{
	if (self = [super init])
	{
		CPParkingServiceFavoritesMock = [[NSMutableSet alloc] init];
	}
	
	return self;
}

#pragma mark - Driveways

- (void)createDrivewayAlLocation:(CLLocationCoordinate2D)location
					   withTitle:(NSString *)title
						 address:(NSString *)address
						   price:(NSNumber *)price
					   schedules:(NSArray<CPParkingScheduleModel *> *)schedules
					 description:(NSString *)description
					 isAvailable:(BOOL)isAvailable
						   image:(UIImage *)image
					successBlock:(CPServiceSuccessBlock)successBlock
				   andErrorBlock:(CPServiceErrorBlock)errorBlock
{
	void(^createDriveway)(id imageId) = ^(id imageId) {
		NSMutableDictionary *params = [NSMutableDictionary dictionary];
		[params cp_addObject:title forKey:@"address1"];
		[params cp_addObject:address forKey:@"address2"];
		[params cp_addObject:@(location.latitude) forKey:@"latitude"];
		[params cp_addObject:@(location.longitude) forKey:@"longitude"];
		[params cp_addObject:price forKey:@"price"];
		[params cp_addObject:imageId forKey:@"imagePath"];
		[params cp_addObject:CPParkingScheduleModelToString(schedules) forKey:@"schedule"];
		[params cp_addObject:isAvailable?@"available":@"unavailable" forKey:@"status"];
		[params cp_addObject:description forKey:@"description"];
		[self.networkService sendJSONRequest:@"/driveway" withMethod:CPNetworkMethodPUT params:@{@"driveway": params}
									callback:^(NSDictionary *object, NSURLResponse *response, NSError *error) {
										if (error) {
											CPSafeCallBlock(errorBlock, error);
										}
										
										dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
											NSMutableDictionary *json = (id)object;
											if (object.count == 0)
											{
												json = [params mutableCopy];
												json[@"schedule"] = [MTLJSONAdapter JSONArrayFromModels:schedules error:nil];
												json[@"location"] = @{
																	  @"latitude": @(location.latitude),
																	  @"longitude": @(location.longitude),
																	  };
											}
											
											NSError *parseError = nil;
											CPPaidParkingInfo *parkingInfo = [CPPaidParkingInfo objectFromDictionary:json  error:&parseError];
											
											dispatch_async(dispatch_get_main_queue(), ^{
												if (parseError) {
													CPSafeCallBlock(errorBlock, NSParsingErrorMake(parseError.userInfo));
												} else {
													CPSafeCallBlock(successBlock, parkingInfo);
												}
											});
										});
									}];
	};
	
	
	if (image == nil) {
		createDriveway(nil);
	} else {
		[self.networkService uploadImage:image withCallback:^(NSDictionary *result, NSURLResponse *response, NSError *error) {
			if (error) {
				CPSafeCallBlock(errorBlock, error);
			}
	
			id imageId = result[@"path"];
			createDriveway(imageId);
		}];
	}
}

- (void)updateDriveway:(CPPaidParkingInfo *)parkingInfo
		 withSchedules:(NSArray<CPParkingScheduleModel *> *)schedules
		   description:(NSString *)description
		   isAvailable:(BOOL)isAvailable
				 image:(UIImage *)image
		  successBlock:(CPServiceSuccessBlock)successBlock
		 andErrorBlock:(CPServiceErrorBlock)errorBlock
{
	void(^updateDriveway)(id imageId) = ^(id imageId) {
		NSString *method = CPNetworkMethodPOST;
		NSString *path = [NSString stringWithFormat:@"/driveway/%@", parkingInfo.objectId];

		NSMutableDictionary *params = [NSMutableDictionary dictionary];
		[params cp_addObject:CPParkingScheduleModelToString(schedules) forKey:@"schedule"];
		[params cp_addObject:description forKey:@"description"];
		[params cp_addObject:isAvailable?@"available":@"unavailable" forKey:@"status"];
		[params cp_addObject:imageId forKey:@"imagePath"];
		
		[self.networkService sendJSONRequest:path withMethod:method params:@{@"driveway": params} callback:^(NSDictionary *object, NSURLResponse *response, NSError *error) {
			if (error) {
				CPSafeCallBlock(errorBlock, error);
			}
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				NSMutableDictionary *json = (id)object;
				if (object.count == 0)
				{
					json = [params mutableCopy];
					json[@"schedule"] = [MTLJSONAdapter JSONArrayFromModels:schedules error:nil];
					json[@"location"] = @{
						@"latitude": @(parkingInfo.location.latitude),
						@"longitude": @(parkingInfo.location.longitude),
					};
				}
				
				NSError *parseError = nil;
				CPPaidParkingInfo *parkingInfo = [CPPaidParkingInfo objectFromDictionary:json  error:&parseError];
				
				dispatch_async(dispatch_get_main_queue(), ^{
					if (parseError) {
						CPSafeCallBlock(errorBlock, NSParsingErrorMake(parseError.userInfo));
					} else {
						CPSafeCallBlock(successBlock, parkingInfo);
					}
				});
			});
		}];
		
	};
	
	if (image == nil) {
		updateDriveway(nil);
	} else {
		[self.networkService uploadImage:image withCallback:^(NSDictionary *result, NSURLResponse *response, NSError *error) {
			if (error) {
				CPSafeCallBlock(errorBlock, error);
			}
			
			id imageId = result[@"path"];
			updateDriveway(imageId);
		}];
	}

//
//
//	[self.networkService sendJSONRequest:path withMethod:method params:@{@"driveway": params} callback:^(id object, NSURLResponse *response, NSError *error) {
//		if (error) {
//			return self.defaultErrorBlock(error);
//		}
//		
//		self->_success = YES;
//		
//		[self actCloseAndNotifyParentWithParking:object];
//	}];

}

#pragma mark - Spots

- (PMKPromise *)requestSpotsWithCoordinate:(CLLocationCoordinate2D)location radius:(CGFloat)radius startTime:(NSDate *)startTime endTime:(NSDate *)endTime
{
	DASSERT(radius >= 1.f);
	
	NSString *method = CPNetworkMethodGET;
	NSString *path = [NSString stringWithFormat:@"/driveway/%lf/%lf/%lu", location.latitude, location.longitude, (unsigned long)radius];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
	[params cp_addObject:NSDateToStringFull(startTime) forKey:@"from"];
	[params cp_addObject:NSDateToStringFull(endTime) forKey:@"to"];
	
	return [self.networkService sendJSONRequest:path withMethod:method params:params].thenInBackground(^(id object) {
		NSError *parseError = nil;
		NSArray<CPPaidParkingInfo *> *items = [MTLJSONAdapter modelsOfClass:CPPaidParkingInfo.class fromJSONArray:object error:&parseError];
		return parseError ? NSParsingErrorMake(parseError.userInfo) : items;
	});
}

- (PMKPromise *)requestUserSpotsList
{
	NSString *method = CPNetworkMethodGET;
	NSString *path = @"/driveway";
	
	return [self.networkService sendJSONRequest:path withMethod:method params:nil].thenInBackground(^(id object) {
		NSError *parseError = nil;
		NSArray<CPPaidParkingInfo *> *items = [CPPaidParkingInfo objectsFromArray:object error:&parseError];
		return parseError ? NSParsingErrorMake(parseError.userInfo) : items;
	});
}

- (PMKPromise *)requestSpotById:(CPObjectModelId)objectId
{
	DASSERT(objectId != nil);
	
	NSString *method = CPNetworkMethodGET;
	NSString *path = [NSString stringWithFormat:@"/driveway/%@", objectId];

	return [self.networkService sendJSONRequest:path withMethod:method params:nil].thenInBackground(^(id object) {
		NSError *parseError = nil;
		CPParkingInfo *item = [CPParkingInfo objectFromDictionary:object error:&parseError];
		return parseError ? NSParsingErrorMake(parseError.userInfo) : item;
	});
}

#pragma mark - Booking

- (PMKPromise *)createBookingForSpot:(CPObjectModelId)spotId from:(NSDate *)fromDate to:(NSDate *)toDate
{
	DASSERT(spotId != nil);
	DASSERT(fromDate != nil);
	DASSERT(toDate != nil);
	
	NSString *from = NSDateToStringFull(fromDate);
	NSString *to = NSDateToStringFull(toDate);
	
	NSString *method = CPNetworkMethodPUT;
	NSString *path = [NSString stringWithFormat:@"/booking"];
	NSDictionary *params = @{@"booking": @{
								@"bookedFrom": from,
								@"bookedTo": to,
								@"driveway_id": spotId }};

	return [self.networkService sendJSONRequest:path withMethod:method params:params].thenInBackground(^(id object) {
		NSError *parseError = nil;
		CPBookingInfoModel *item = [CPBookingInfoModel objectFromDictionary:object error:&parseError];
		return parseError ? NSParsingErrorMake(parseError.userInfo) : item;
	});
}

- (PMKPromise *)renewBookingWithId:(CPObjectModelId)bookingId to:(NSDate *)toDate
{
	DASSERT(bookingId != nil);
	DASSERT(toDate != nil);
	
	NSString *method = CPNetworkMethodPOST;
	NSString *path = [NSString stringWithFormat:@"/booking/%@", bookingId];
	NSDictionary *params = @{ @"bookedTo": NSDateToStringFull(toDate) };
	
	return [self.networkService sendJSONRequest:path withMethod:method params:params].thenInBackground(^(id object) {
		NSError *parseError = nil;
		CPBookingInfoModel *item = [CPBookingInfoModel objectFromDictionary:object error:&parseError];
		return parseError ? NSParsingErrorMake(parseError.userInfo) : item;
	});
}

- (PMKPromise *)cancelBooking:(CPObjectModelId)bookingId
{
	DASSERT(bookingId != nil);
	
	NSString *method = CPNetworkMethodDELETE;
	NSString *path = [NSString stringWithFormat:@"/booking/%@", bookingId];
	
	return [self.networkService sendJSONRequest:path withMethod:method params:nil];
}

- (PMKPromise *)requestBookingList
{
	NSString *method = CPNetworkMethodGET;
	NSString *path = @"/booking";
	
	return [self.networkService sendJSONRequest:path withMethod:method params:nil].thenInBackground(^(id object) {
		NSError *parseError = nil;
		NSArray<CPBookingInfoModel *> *items = [CPBookingInfoModel objectsFromArray:object error:&parseError];
		return parseError ? NSParsingErrorMake(parseError.userInfo) : items;
	});
}

- (PMKPromise *)requestBookingById:(CPObjectModelId)bookingId
{
	DASSERT(bookingId != nil);
	
	NSString *method = CPNetworkMethodGET;
	NSString *path = [NSString stringWithFormat:@"/booking/%@", bookingId];
	
	return [self.networkService sendJSONRequest:path withMethod:method params:nil].thenInBackground(^(id object) {
		NSError *parseError = nil;
		CPBookingInfoModel *item = [CPBookingInfoModel objectFromDictionary:object error:&parseError];
		return (parseError ? NSParsingErrorMake(parseError.userInfo) : item);
	});
}

#pragma mark - Favorites

- (PMKPromise *)createFavoriteForParking:(CPObjectModelId)parkingId
{
	DASSERT(parkingId != nil);
	
	NSString *method = CPNetworkMethodPUT;
	NSString *path = [NSString stringWithFormat:@"/driveway/favorites/%@", parkingId];
	
	return [self.networkService sendJSONRequest:path withMethod:method params:nil].thenInBackground(^{
		[CPParkingServiceFavoritesMock addObject:parkingId];
	});
}

- (PMKPromise *)removeFavoriteParking:(CPObjectModelId)parkingId
{
	DASSERT(parkingId != nil);
	
	NSString *method = CPNetworkMethodDELETE;
	NSString *path = [NSString stringWithFormat:@"/driveway/favorites/%@", parkingId];

	return [self.networkService sendJSONRequest:path withMethod:method params:nil].thenInBackground(^{
		[CPParkingServiceFavoritesMock removeObject:parkingId];
	});
}

- (PMKPromise *)requestFavoritesList
{
	NSString *method = CPNetworkMethodGET;
	NSString *path = @"/driveway/favorites";

	return [self.networkService sendJSONRequest:path withMethod:method params:nil].thenInBackground(^(id result) {
		NSError *parseError = nil;
		NSArray<CPParkingInfo *> *items = [CPParkingInfo objectsFromArray:result error:&parseError];
		return (parseError ? NSParsingErrorMake(parseError.userInfo) : items);
		
	}).then(^(NSArray<CPParkingInfo *> *items) {
		[CPParkingServiceFavoritesMock removeAllObjects];
		[items enumerateObjectsUsingBlock:^(CPParkingInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			[CPParkingServiceFavoritesMock addObject:obj.objectId];
		}];
		return items;
	});
}

@end
