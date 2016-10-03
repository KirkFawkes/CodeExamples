//
//  CPViewControllersAssembly.m
//  CityParking
//
//  Created by Igor Zubko on 06.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPViewControllersAssembly.h"
// Assemblies
#import "CPNetworkAssembly.h"
#import "CPApplicationAssembly.h"
// View Controllers
#import "CPViewController.h"
#import "CPFavoriteViewController.h"
#import "CPMapViewController.h"
#import "CPMainMenuViewController.h"
#import "CPDateTimeSelectionViewController.h"
#import "CPPostSpotMapViewController.h"
#import "CPPostSpotDetailsViewController.h"
#import "CPPhoneConfirmationViewController.h"
#import "CPBookingSpotInfoViewController.h"
#import "CPPromotionsViewController.h"
#import "CPAddCreditCardViewController.h"
#import "CPAccountsListViewController.h"
#import "CPAddBankAccountViewController.h"
#import "CPTransferBookingViewController.h"
#import "CPForgotPasswordViewController.h"
#import "CPLoadingViewController.h"
// refactor thsis imports

@implementation CPViewControllersAssembly

- (CPViewController *)baseViewController
{
	return [TyphoonDefinition withClass:[CPViewController class] configuration:^(TyphoonDefinition *definition) {
		[definition injectProperty:@selector(analiticsService) with:self.applicationAssembly.analitics];
		[definition injectProperty:@selector(appearanceService) with:self.applicationAssembly.appearance];
		[definition injectProperty:@selector(routerService) with:self.applicationAssembly.router];
		[definition injectProperty:@selector(userService) with:self.applicationAssembly.user];
		[definition injectProperty:@selector(configService) with:self.applicationAssembly.config];
		
		[definition injectProperty:@selector(networkService) with:self.networkAssembly.networkService];
		
		[definition injectProperty:@selector(activityIndicatorService) with:self.networkAssembly.activityIndicatorService];
	}];
}

#pragma mark - Controllers

- (CPMapViewController *)mapViewController
{
	return [TyphoonDefinition withParent:[self baseViewController] class:[CPMapViewController class] configuration:^(TyphoonDefinition *definition) {
		[definition injectProperty:@selector(geocodingService) with:self.networkAssembly.geocodingService];
		[definition injectProperty:@selector(locationService) with:self.applicationAssembly.location];
		[definition injectProperty:@selector(parkingService) with:self.applicationAssembly.parking];
	}];
}

- (CPFavoriteViewController *)favoriteViewController
{
	return [TyphoonDefinition withParent:[self baseViewController] class:[CPFavoriteViewController class] configuration:^(TyphoonDefinition *definition) {
		[definition injectProperty:@selector(parkingService) with:self.applicationAssembly.parking];
	}];
}

- (CPDateTimeSelectionViewController *)dateTimeSelectionViewController
{
	return [TyphoonDefinition withParent:[self baseViewController] class:[CPDateTimeSelectionViewController class] configuration:^(TyphoonDefinition *definition) {
		[definition injectProperty:@selector(parkingService) with:self.applicationAssembly.parking];
		[definition injectProperty:@selector(notificationService) with:self.applicationAssembly.notification];
	}];
}

- (CPBookingSpotInfoViewController *)bookingSpotInfoViewController
{
	return [TyphoonDefinition withParent:[self baseViewController] class:[CPBookingSpotInfoViewController class] configuration:^(TyphoonDefinition *definition) {
		[definition injectProperty:@selector(parkingService) with:self.applicationAssembly.parking];
	}];
}

- (CPTransferBookingViewController *)transferBookingViewController
{
	return [TyphoonDefinition withParent:[self baseViewController] class:[CPTransferBookingViewController class] configuration:^(TyphoonDefinition *definition) {
		[definition injectProperty:@selector(parkingService) with:self.applicationAssembly.parking];
	}];
}

- (CPLoadingViewController *)loadingViewController
{
	return [TyphoonDefinition withParent:[self baseViewController] class:[CPLoadingViewController class] configuration:^(TyphoonDefinition *definition) {
		[definition injectProperty:@selector(parkingService) with:self.applicationAssembly.parking];
	}];
}

#pragma mark - Controllers [Authrorization]

- (CPPhoneConfirmationViewController *)phoneConfirmationViewController
{
	return [TyphoonDefinition withParent:[self baseViewController] class:[CPPhoneConfirmationViewController class]];
}

- (CPForgotPasswordViewController *)forgotPasswordViewController
{
	return [TyphoonDefinition withParent:[self baseViewController] class:[CPForgotPasswordViewController class]];
}

#pragma mark - Controllers [Menu]

- (CPMainMenuViewController *)mainMenuViewController
{
	return [TyphoonDefinition withParent:[self baseViewController] class:[CPMainMenuViewController class]];
}

#pragma mark - Controllers [Post Spot]

- (CPPostSpotMapViewController *)postSpotMapViewController
{
	return [TyphoonDefinition withParent:[self baseViewController] class:[CPPostSpotMapViewController class] configuration:^(TyphoonDefinition *definition) {
		[definition injectProperty:@selector(geocodingService) with:self.networkAssembly.geocodingService];
		[definition injectProperty:@selector(locationProvider) with:self.applicationAssembly.location];
		[definition injectProperty:@selector(parkingService) with:self.applicationAssembly.parking];
	}];
}

- (CPPostSpotDetailsViewController *)postSpotDetailsViewController
{
	return [TyphoonDefinition withParent:[self baseViewController] class:[CPPostSpotDetailsViewController class] configuration:^(TyphoonDefinition *definition) {
		[definition injectProperty:@selector(geocodingService) with:self.networkAssembly.geocodingService];
		[definition injectProperty:@selector(notificationService) with:self.applicationAssembly.notification];
		[definition injectProperty:@selector(parkingService) with:self.applicationAssembly.parking];
	}];
}

#pragma mark - Controllers [Promotions]

- (CPPromotionsViewController *)promotionsViewController
{
	return [TyphoonDefinition withParent:[self baseViewController] class:[CPPromotionsViewController class] configuration:^(TyphoonDefinition *definition) {
		[definition injectProperty:@selector(promotionService) with:self.applicationAssembly.promotion];
	}];
}

#pragma mark - Controllers [Payments]

- (CPAddCreditCardViewController *)addCreditCardController
{
	return [TyphoonDefinition withParent:[self baseViewController] class:[CPAddCreditCardViewController class]];
}

- (CPAddBankAccountViewController *)addBankAccountController
{
	return [TyphoonDefinition withParent:[self baseViewController] class:[CPAddBankAccountViewController class]];
}

- (CPAccountsListViewController *)accountsListViewController
{
	return [TyphoonDefinition withParent:[self baseViewController] class:[CPAccountsListViewController class]];
}

@end
