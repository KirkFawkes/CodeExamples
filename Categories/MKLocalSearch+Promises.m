//
//  MKLocalSearch+Promises.m
//  CityParking
//
//  Created by Igor on 21.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import "MKLocalSearch+Promises.h"
#import <PromiseKit/PromiseKit.h>

@implementation MKLocalSearch (Promises)

- (PMKPromise *)pmk_start
{
	return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
		[self startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
			if (error != nil)
				reject(error);
			else
				fulfill(response);
		}];
	}];
}

@end
