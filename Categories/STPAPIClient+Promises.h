//
//  STPAPIClient+Promises.h
//  CityParking
//
//  Created by Igor Zubko on 23.03.16.
//  Copyright © 2016 Fastforward. All rights reserved.
//

#import <Stripe/Stripe.h>

@class PMKPromise;

@interface STPAPIClient (Promises)

- (PMKPromise *)cp_createTokenWithCard:(STPCardParams *)card;

@end
