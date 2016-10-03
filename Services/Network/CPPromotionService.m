//
//  CPPromotionService.m
//  CityParking
//
//  Created by Igor Zubko on 21.12.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPPromotionService.h"
#import "CPNetworkService.h"

@interface CPPromotionService ()
@property (nonatomic, weak) id<CPNetworkServiceProtocol> networkService;
@end

@implementation CPPromotionService

- (instancetype)initWithNetworkService:(id<CPNetworkServiceProtocol>)networkService
{
	if (self = [super init])
	{
		self.networkService = networkService;
	}
	
	return self;
}

- (void)dealloc
{
	DLOGMETHODNAME();
}

#pragma mark -

- (PMKPromise *)activatePromocode:(NSString *)promocode
{
	return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
		[self activatePromocode:promocode successBlock:fulfill errorBlock:reject];
	}];
}

- (void)activatePromocode:(NSString *)promocode successBlock:(CPServiceSuccessBlock)successBlock errorBlock:(CPServiceErrorBlock)errorBlock
{
	DASSERT(promocode.length > 0);
	
	NSString *path = @"/promo/code";
	NSString *method = CPNetworkMethodPOST;
	NSDictionary *params = @{@"code": promocode};
	
	[self.networkService sendJSONRequest:path withMethod:method params:params callback:^(NSDictionary *object, NSURLResponse *response, NSError *error) {
		if (error != nil) {
			CPSafeCallBlock(errorBlock, error);
			return;
		}
		
		CPSafeCallBlock(successBlock, object);
	}];
}

@end
