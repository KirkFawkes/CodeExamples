//
//  CPFreeParkingInfo.h
//  CityParking
//
//  Created by Igor Zubko on 05.12.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPParkingInfo.h"

@interface CPFreeParkingInfo : CPParkingInfo
@property (nonatomic, readonly) NSArray<NSValue *> *lineCoordinates;
@end
