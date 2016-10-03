//
//  CLGeocoder+Promises.m
//  CityParking
//
//  Created by Igor on 21.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import "CLGeocoder+Promises.h"
#import <PromiseKit/PromiseKit.h>

@implementation CLGeocoder (Promises)

- (PMKPromise *)pmk_geocodeAddressString:(NSString *)addressString
{
	return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
		[self geocodeAddressString:addressString completionHandler:^(NSArray *placemarks, NSError *error) {
			if (error) {
				reject(error);
			} else {
				fulfill(placemarks);
			}
		}];
	}];
}

@end
