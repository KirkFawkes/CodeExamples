//
//  STPAPIClient+Promises.m
//  CityParking
//
//  Created by Igor Zubko on 23.03.16.
//  Copyright © 2016 Fastforward. All rights reserved.
//

#import "STPAPIClient+Promises.h"
#import <PromiseKit/PromiseKit.h>

@implementation STPAPIClient (Promises)

- (PMKPromise *)cp_createTokenWithCard:(STPCardParams *)card
{
	return [PMKPromise promiseWithAdapter:^(PMKAdapter adapter) {
		[self createTokenWithCard:card completion:adapter];
	}];
}

@end
