//
//  CPApplicationAssembly.m
//  CityParking
//
//  Created by Igor Zubko on 06.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPApplicationAssembly.h"
//
#import "AppDelegate.h"
//
#import "CPAppearance.h"
#import "CPAnalitics.h"
#import "CPNetworkAssembly.h"
#import "CPUserService.h"
#import "CPConfigService.h"
#import "CPLocationProvider.h"
#import "CPParkingService.h"
#import "CPNotificaitonService.h"
#import "CPPromotionService.h"
#import "CPRouterService.h"

@implementation CPApplicationAssembly

- (CPAppearance *)appearance
{
	return [TyphoonDefinition withClass:[CPAppearance class] configuration:^(TyphoonDefinition *definition) {
		definition.scope = TyphoonScopeSingleton;
	}];
}

- (CPRouterService *)router
{
	return [TyphoonDefinition withClass:[CPRouterService class] configuration:^(TyphoonDefinition *definition) {
		definition.scope = TyphoonScopeSingleton;
	}];
}

- (id<CPAnaliticsServiceProtocol>)analitics
{
	return [TyphoonDefinition withClass:[CPAnalitics class] configuration:^(TyphoonDefinition *definition) {
		definition.scope = TyphoonScopeSingleton;
	}];
}

- (CPConfigService *)config
{
	return [TyphoonDefinition withClass:[CPConfigService class] configuration:^(TyphoonDefinition *definition) {
		definition.scope = TyphoonScopeSingleton;
	}];
}

- (CPLocationProvider *)location
{
	return [TyphoonDefinition withClass:[CPLocationProvider class] configuration:^(TyphoonDefinition *definition) {
		definition.scope = TyphoonScopeSingleton;
	}];
}

- (CPParkingService *)parking
{
	return [TyphoonDefinition withClass:[CPParkingService class] configuration:^(TyphoonDefinition *definition) {
		definition.scope = TyphoonScopeSingleton;
		
		[definition injectProperty:@selector(networkService) with:self.networkAssembly.networkService];
	}];
}

- (id<CPNotificaitonServiceProtocol>)notification
{
	return [TyphoonDefinition withClass:[CPNotificaitonService class] configuration:^(TyphoonDefinition *definition) {
		definition.scope = TyphoonScopeWeakSingleton;
		
		[definition injectProperty:@selector(userService) with:self.user];
		[definition injectProperty:@selector(parkingService) with:self.parking];
		[definition injectProperty:@selector(networkService) with:self.networkAssembly.networkService];
		[definition injectProperty:@selector(analiticsService) with:self.analitics];
	}];
}

- (id<CPUserServiceProtocol>)user
{
	return [TyphoonDefinition withClass:[CPUserService class] configuration:^(TyphoonDefinition *definition) {
		definition.scope = TyphoonScopeSingleton;
		
		[definition injectProperty:@selector(networkService) with:self.networkAssembly.networkService];
		[definition injectProperty:@selector(configService) with:[self config]];
		[definition injectProperty:@selector(analiticsService) with:self.analitics];
	}];
}

- (id<CPPromotionService>)promotion
{
	return [TyphoonDefinition withClass:[CPPromotionService class] configuration:^(TyphoonDefinition *definition) {
		definition.scope = TyphoonScopeWeakSingleton;
		
		[definition injectMethod:@selector(initWithNetworkService:) parameters:^(TyphoonMethod *method) {
			[method injectParameterWith:self.networkAssembly.networkService];
		}];
	}];
}

#pragma mark -

- (AppDelegate *)appDelegate
{
	return [TyphoonDefinition withClass:[AppDelegate class] configuration:^(TyphoonDefinition *definition) {
		[definition injectProperty:@selector(appearanceService) with:self.appearance];
		[definition injectProperty:@selector(analiticsService) with:self.analitics];
		[definition injectProperty:@selector(userService) with:self.user];
		[definition injectProperty:@selector(notificationService) with:self.notification];
	}];
}

@end
