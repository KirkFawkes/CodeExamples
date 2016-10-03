//
//  CPParkingInfo.h
//  CityParking
//
//  Created by Igor Zubko on 06.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

// System
#import <UIKit/UIColor.h>
#import <CoreLocation/CLLocation.h>
// Pods
#import <Mantle/Mantle.h>
// Models
#import "CPObjectModel.h"
#import "CPParkingScheduleModel.h"
//
#import <DateTools/DateTools.h>

typedef NS_ENUM(NSInteger, CPParkingInfoAvailableStatus) {
	CPParkingInfoAvailableStatusUnknown,
	CPParkingInfoAvailableStatusAvailable,
	CPParkingInfoAvailableStatusUnavailable,
	CPParkingInfoAvailableStatusOccupied,
};

#pragma mark - Base

@interface CPParkingInfo : CPObjectModel
@property (nonatomic, assign) CPParkingInfoAvailableStatus status;

@property (nonatomic, retain) NSDate *reservedFromDate;
@property (nonatomic, retain) NSDate *reservedToDate;

@end

extern NSNumber *ExtractNumber(id value);
extern BOOL ExtractBolean(id value);

#import "CPPaidParkingInfo.h"
#import "CPFreeParkingInfo.h"