//
//  MKLocalSearch+Promises.h
//  CityParking
//
//  Created by Igor on 21.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import <MapKit/MapKit.h>

@class PMKPromise;
@interface MKLocalSearch (Promises)

- (PMKPromise *)pmk_start;

@end
