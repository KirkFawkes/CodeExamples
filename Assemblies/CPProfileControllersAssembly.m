//
//  CPProfileControllersAssembly.m
//  CityParking
//
//  Created by Igor Zubko on 02.03.16.
//  Copyright © 2016 Fastforward. All rights reserved.
//

#import "CPProfileControllersAssembly.h"
// Assemblies
#import "CPNetworkAssembly.h"
#import "CPApplicationAssembly.h"
#import "CPViewControllersAssembly.h"
// controllers
#import "CPUserProfileViewController.h"
#import "CPPasswordChangeViewController.h"

@implementation CPProfileControllersAssembly

- (CPUserProfileViewController *)userProfileViewController
{
	return [TyphoonDefinition withParent:[self.viewControllersAssembly baseViewController] class:[CPUserProfileViewController class]];
}

- (CPPasswordChangeViewController *)passwordResetViewController
{
	return [TyphoonDefinition withParent:[self.viewControllersAssembly baseViewController] class:[CPPasswordChangeViewController class]];
}


@end
