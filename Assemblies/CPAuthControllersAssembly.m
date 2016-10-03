//
//  CPAuthControllersAssembly.m
//  CityParking
//
//  Created by Igor Zubko on 16.02.16.
//  Copyright © 2016 Fastforward. All rights reserved.
//

#import "CPAuthControllersAssembly.h"
// Assemblies
#import "CPNetworkAssembly.h"
#import "CPApplicationAssembly.h"
#import "CPViewControllersAssembly.h"
// ViewControllers
#import "CPWelcomeViewController.h"
#import "CPSignInViewController.h"
#import "CPSignUpViewController.h"
#import "CPPhoneEditorViewController.h"

@implementation CPAuthControllersAssembly

- (CPWelcomeViewController *)welcomeViewController
{
	return [TyphoonDefinition withParent:[self.viewControllersAssembly baseViewController] class:[CPWelcomeViewController class]];
}

- (CPSignUpViewController *)signupViewController
{
	return [TyphoonDefinition withParent:self.viewControllersAssembly.baseViewController class:[CPSignUpViewController class]];
}

- (CPSignInViewController *)signinViewController
{
	return [TyphoonDefinition withParent:self.viewControllersAssembly.baseViewController class:[CPSignInViewController class]];
}

- (CPPhoneEditorViewController *)phoneEditorViewController
{
	return [TyphoonDefinition withParent:self.viewControllersAssembly.baseViewController class:[CPPhoneEditorViewController class] configuration:^(TyphoonDefinition *definition) {
		[definition injectProperty:@selector(userService) with:self.applicationAssembly.user];
		[definition injectProperty:@selector(analiticsService) with:self.applicationAssembly.analitics];
	}];
}

@end
