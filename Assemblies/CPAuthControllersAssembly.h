//
//  CPAuthControllersAssembly.h
//  CityParking
//
//  Created by Igor Zubko on 16.02.16.
//  Copyright © 2016 Fastforward. All rights reserved.
//

#import <Typhoon/Typhoon.h>

@class CPNetworkAssembly, CPApplicationAssembly, CPViewControllersAssembly;

@interface CPAuthControllersAssembly : TyphoonAssembly
@property(nonatomic, strong, readonly) CPNetworkAssembly *networkAssembly;
@property(nonatomic, strong, readonly) CPApplicationAssembly *applicationAssembly;
@property(nonatomic, strong, readonly) CPViewControllersAssembly *viewControllersAssembly;

@end
