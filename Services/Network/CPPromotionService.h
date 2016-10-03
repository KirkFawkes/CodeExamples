//
//  CPPromotionService.h
//  CityParking
//
//  Created by Igor Zubko on 21.12.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>

@protocol CPNetworkServiceProtocol;

@protocol CPPromotionService<NSObject>
// Promocodes
- (void)activatePromocode:(NSString *)promocode successBlock:(CPServiceSuccessBlock)successBlock errorBlock:(CPServiceErrorBlock)errorBlock;
- (PMKPromise *)activatePromocode:(NSString *)promocode;
//
@end

@interface CPPromotionService : NSObject<CPPromotionService>
- (instancetype)initWithNetworkService:(id<CPNetworkServiceProtocol>)networkService;
@end
