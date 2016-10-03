//
//  CPParkingService.h
//  CityParking
//
//  Created by Igor Zubko on 20.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

// System
#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "CPObjectModel.h"
#import "CPParkingScheduleModel.h"
// Other
#import "defines.h"
#import <PromiseKit/PromiseKit.h>

// Only for demo version. Must be removed in future
extern NSMutableSet *CPParkingServiceFavoritesMock;

extern NSString *kParkingServiceParkingUpdated;

typedef enum : NSUInteger {
	CPParkingServiceTypeFree,
	CPParkingServiceTypePaid,
} CPParkingServiceType;

@protocol CPNetworkServiceProtocol;
@class CPParkingInfo, CPObjectModel, CPPaidParkingInfo;

@protocol CPParkingService <NSObject>

- (void)createDrivewayAlLocation:(CLLocationCoordinate2D)location
					   withTitle:(NSString *)title
						 address:(NSString *)address
						   price:(NSNumber *)price
					   schedules:(NSArray<CPParkingScheduleModel *> *)schedules
					 description:(NSString *)description
					 isAvailable:(BOOL)isAvailable
						   image:(UIImage *)image
					successBlock:(CPServiceSuccessBlock)successBlock
				   andErrorBlock:(CPServiceErrorBlock)errorBlock;

- (void)updateDriveway:(CPPaidParkingInfo *)parkingInfo
		 withSchedules:(NSArray<CPParkingScheduleModel *> *)schedules
		   description:(NSString *)description
		   isAvailable:(BOOL)isAvailable
				 image:(UIImage *)image
		  successBlock:(CPServiceSuccessBlock)successBlock
		 andErrorBlock:(CPServiceErrorBlock)errorBlock;

#pragma mark - Spots

/**
 *  Search spots
 *
 *  @param location  Center coordinate
 *  @param radius    Radius of search (in meters)
 *  @param startTime have free time from… (can be nil)
 *  @param endTime   have free time to… (can be nil)
 *
 *  @return NSArray<CPPaidParkingInfo *> *
 */
- (PMKPromise *)requestSpotsWithCoordinate:(CLLocationCoordinate2D)location radius:(CGFloat)radius startTime:(NSDate *)startTime endTime:(NSDate *)endTime;

/**
 *  Request list of user spots
 *
 *  @return NSArray<CPPaidParkingInfo *> *
 */
- (PMKPromise *)requestUserSpotsList;

/**
 *  Request information about target spot
 *
 *  @param objectId id of target spot
 *
 *  @return CPParkingInfo *
 */
- (PMKPromise *)requestSpotById:(CPObjectModelId)objectId;

#pragma mark - Booking

/**
 *  Create booking for target spot
 *
 *  @param spotId   id of target spot
 *  @param fromDate booking start time
 *  @param toDate   booking end time
 *
 *  @return CPBookingInfoModel *
 */
- (PMKPromise *)createBookingForSpot:(CPObjectModelId)spotId from:(NSDate *)fromDate to:(NSDate *)toDate;

/**
 *  Renew existing booking
 *
 *  @param bookingId id of target booking
 *  @param toDate    new booking end time
 *
 *  @return CPBookingInfoModel *
 */
- (PMKPromise *)renewBookingWithId:(CPObjectModelId)bookingId to:(NSDate *)toDate;

/**
 *  Cancel target booking
 *
 *  @param bookingId id of target booking
 */
- (PMKPromise *)cancelBooking:(CPObjectModelId)bookingId;

/**
 *  Return list of user bookings
 *
 *  @return NSArray<CPBookingInfoModel *> *
 */
- (PMKPromise *)requestBookingList;

/**
 *  Request onformation about target booking
 *
 *  @param bookingId id of target booking
 *
 *  @return CPBookingInfoModel *
 */
- (PMKPromise *)requestBookingById:(CPObjectModelId)bookingId;

#pragma mark - Favorites

/**
 *  Add spot to favorites list
 *
 *  @param parkingId id of target spot
 */
- (PMKPromise *)createFavoriteForParking:(CPObjectModelId)parkingId;

/**
 *  Remove spot from favorits list
 *
 *  @param parkingId id of target spot
 */
- (PMKPromise *)removeFavoriteParking:(CPObjectModelId)parkingId;

/**
 *  Request user favorites spost
 *
 *  @return NSArray<CPParkingInfo *> *
 */
- (PMKPromise *)requestFavoritesList;

@end

@interface CPParkingService : NSObject<CPParkingService>
@property (nonatomic, retain) id<CPNetworkServiceProtocol> networkService;
@end
