//
//  CPApplicationAssembly.h
//  CityParking
//
//  Created by Igor Zubko on 06.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "TyphoonAssembly.h"

@class CPAppearance, CPConfigService, CPLocationProvider, CPNotificaitonService, CPRouterService;
@class CPNetworkAssembly, CPParkingService, CPAnalitics, AppDelegate;

@protocol CPPromotionService, CPUserServiceProtocol, CPAnaliticsServiceProtocol, CPNotificaitonServiceProtocol;

@interface CPApplicationAssembly : TyphoonAssembly
@property(nonatomic, strong, readonly) CPNetworkAssembly *networkAssembly;

- (CPParkingService *)parking;
- (CPAppearance *)appearance;
- (CPRouterService *)router;
- (id<CPAnaliticsServiceProtocol>)analitics;
- (id<CPUserServiceProtocol>)user;
- (CPConfigService *)config;
- (CPLocationProvider *)location;
- (id<CPNotificaitonServiceProtocol>)notification;
- (id<CPPromotionService>)promotion;
- (AppDelegate *)appDelegate;

@end
