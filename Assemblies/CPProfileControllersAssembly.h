//
//  CPProfileControllersAssembly.h
//  CityParking
//
//  Created by Igor Zubko on 02.03.16.
//  Copyright © 2016 Fastforward. All rights reserved.
//

#import <Typhoon/Typhoon.h>

@class CPNetworkAssembly, CPApplicationAssembly, CPViewControllersAssembly;

@interface CPProfileControllersAssembly : TyphoonAssembly
@property(nonatomic, strong, readonly) CPNetworkAssembly *networkAssembly;
@property(nonatomic, strong, readonly) CPApplicationAssembly *applicationAssembly;
@property(nonatomic, strong, readonly) CPViewControllersAssembly *viewControllersAssembly;

@end
