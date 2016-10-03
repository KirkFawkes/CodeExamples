//
//  CPViewControllersAssembly.h
//  CityParking
//
//  Created by Igor Zubko on 06.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "TyphoonAssembly.h"

@class CPNetworkAssembly, CPApplicationAssembly, CPViewController;

@interface CPViewControllersAssembly : TyphoonAssembly
@property(nonatomic, strong, readonly) CPNetworkAssembly *networkAssembly;
@property(nonatomic, strong, readonly) CPApplicationAssembly *applicationAssembly;

- (CPViewController *)baseViewController;

@end
