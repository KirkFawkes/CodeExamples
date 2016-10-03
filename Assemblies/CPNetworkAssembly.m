//
//  CPNetworkAssembly.m
//  CityParking
//
//  Created by Igor Zubko on 06.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPNetworkAssembly.h"
// Services
#import "CPNetworkService.h"
#import "CPGeocoderService.h"
#import "CPApplicationAssembly.h"
#import "CPNetworkIndicatorService.h"
// Other
#import "constants.h"

@implementation CPNetworkAssembly

- (id<CPNetworkServiceProtocol>)networkService
{
	return [TyphoonDefinition withClass:[CPNetworkService class] configuration:^(TyphoonDefinition *definition) {
		definition.scope = TyphoonScopeSingleton;
		
		[definition injectProperty:@selector(activityIndicatorService) with:self.activityIndicatorService];
		[definition injectProperty:@selector(userService) with:self.applicationAssembly.user];
		
		[definition useInitializer:@selector(initWithBaseUrl:) parameters:^(TyphoonMethod *initializer) {
			NSURL *baseUrl = [NSURL URLWithString:CPConfigServerBaseUrl];
			[initializer injectParameterWith:baseUrl];
		}];
	}];
}

- (CPGeocoderService *)geocodingService
{
	return [TyphoonDefinition withClass:[CPGeocoderService class]];
}

- (id<CPNetworkIndicatorServiceProtocol>)activityIndicatorService
{
	return [TyphoonDefinition withClass:[CPNetworkIndicatorService class] configuration:^(TyphoonDefinition *definition) {
		definition.scope = TyphoonScopeWeakSingleton;
	}];
}

@end
