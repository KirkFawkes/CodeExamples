//
//  CPBookingInfoModel.h
//  CityParking
//
//  Created by Igor Zubko on 30.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPObjectModel.h"

@class CPParkingInfo;

@interface CPBookingInfoModel : CPObjectModel
@property (nonatomic, readonly, retain) NSDate *startTime;
@property (nonatomic, readonly, retain) NSDate *endTime;
@property (nonatomic, readonly, assign) CGFloat amount;
@property (nonatomic, readonly, retain) CPParkingInfo *parking;
@end
