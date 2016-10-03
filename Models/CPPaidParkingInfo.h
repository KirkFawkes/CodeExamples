//
//  CPPaidParkingInfo.h
//  CityParking
//
//  Created by Igor Zubko on 04.12.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPParkingInfo.h"

typedef enum : NSUInteger {
	CPPaidParkingInfoCurrentStatusUnknown,
	CPPaidParkingInfoCurrentStatusAvailable,
	CPPaidParkingInfoCurrentStatusUnavailable,
	CPPaidParkingInfoCurrentStatusOccupied,
} CPPaidParkingInfoCurrentStatus;

@interface CPPaidParkingInfo : CPParkingInfo
@property (nonatomic, readonly, retain) NSString *address1;
@property (nonatomic, readonly, retain) NSString *address2;
@property (nonatomic, readonly, retain) NSURL *photoUrl;
@property (nonatomic, readonly, assign) CGFloat price;
@property (nonatomic, readonly, assign) CGFloat distance;
@property (nonatomic, readonly, assign) CLLocationCoordinate2D location;
@property (nonatomic, readonly, retain) NSArray<CPParkingScheduleModel *> *schedule;
@property (nonatomic, readonly, assign) BOOL isAvailable;
@property (nonatomic, readonly, retain) NSString *spotDescription;

@property (nonatomic, readonly, retain) CPObjectModelId bookingId;

@property (nonatomic, readonly, retain) NSArray<DTTimePeriod *> *bookingList;

@property (nonatomic, readonly, assign) CPPaidParkingInfoCurrentStatus currentStatus;
@property (nonatomic, readonly, retain) NSDate *currentStatusDate;

@property (nonatomic, readonly, retain) NSDictionary *nearestBooking;

- (BOOL)isBooked;
- (void)setIsBooked:(CPObjectModelId)bookingId; // quick fix

- (UIColor *)statusColor;
- (NSString *)statusText;

- (NSString *)fullAddress;

@end
