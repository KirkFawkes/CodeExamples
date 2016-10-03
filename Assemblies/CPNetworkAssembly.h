//
//  CPNetworkAssembly.h
//  CityParking
//
//  Created by Igor Zubko on 06.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "TyphoonAssembly.h"

@protocol CPNetworkServiceProtocol, CPNetworkIndicatorServiceProtocol;
@class CPGeocoderService, CPApplicationAssembly;

@interface CPNetworkAssembly : TyphoonAssembly
@property(nonatomic, strong, readonly) CPApplicationAssembly *applicationAssembly;

- (id<CPNetworkServiceProtocol>)networkService;
- (CPGeocoderService *)geocodingService;
- (id<CPNetworkIndicatorServiceProtocol>)activityIndicatorService;

@end
