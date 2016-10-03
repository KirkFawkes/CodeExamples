//
//  CLGeocoder+Promises.h
//  CityParking
//
//  Created by Igor on 21.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@class PMKPromise;
@interface CLGeocoder (Promises)

- (PMKPromise *)pmk_geocodeAddressString:(NSString *)addressString;

@end
