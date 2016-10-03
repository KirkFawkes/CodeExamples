//
//  CPLocationProvider.m
//  CityParking
//
//  Created by Igor on 21.08.15.
//  Copyright (c) 2015 Fastforward. All rights reserved.
//

#import "CPLocationProvider.h"
#import <PromiseKit/PromiseKit.h>

@interface CPLocationProvider () <CLLocationManagerDelegate>
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableSet *authCallbacks;
@end

@implementation CPLocationProvider

- (instancetype)init
{
	if (self = [super init])
	{
		self.preAuthorizationBlock = nil;
		
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
		self.locationManager.distanceFilter = 1000; //In meters
	}
	
	return self;
}

- (void)startUpdatingLocation
{
}

- (void)requestAccess:(CPLocationProviderAuthChangedBlock)block
{
	if (self.isAuthorized)
		return block(self.authorizationStatus);

	if (self.authCallbacks == nil)
		self.authCallbacks = [[NSMutableSet alloc] init];
	[self.authCallbacks addObject:block];
	
	@weakify(self);
	self.preAuthorizationBlock(^{
		@strongify(self);
		
		if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
			[self.locationManager requestWhenInUseAuthorization];
		} else {
			[self.locationManager startUpdatingLocation];
			[self.locationManager stopUpdatingLocation];
		}
	});
}

#pragma mark -

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	NSMutableSet *blocks = self.authCallbacks;
	self.authCallbacks = nil;

	dispatch_async(dispatch_get_main_queue(), ^{
		[blocks enumerateObjectsUsingBlock:^(CPLocationProviderAuthChangedBlock block, BOOL *stop) {
			block(status);
		}];
	});
}

#pragma mark - Properties

- (void)setPreAuthorizationBlock:(CPLocationProviderPreAuthBlock)preAuthorizationBlock
{
	if (preAuthorizationBlock == nil) {
		preAuthorizationBlock = ^(CPLocationProviderPreAuthDoneBlock done) {
			done();
		};
	}
	
	_preAuthorizationBlock = preAuthorizationBlock;
}

- (CLAuthorizationStatus)authorizationStatus
{
	return [CLLocationManager authorizationStatus];
}

- (BOOL)isNotAuthorized
{
	return (self.authorizationStatus == kCLAuthorizationStatusNotDetermined);
}

- (BOOL)isAuthorized
{
	BOOL result = NO;
	
	switch (self.authorizationStatus)
	{
#if __IPHONE_8_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
		case kCLAuthorizationStatusAuthorizedAlways:
		case kCLAuthorizationStatusAuthorizedWhenInUse:
#else
		case kCLAuthorizationStatusAuthorized:
#endif
			result = YES;
			break;
			
		default:
			result = NO;
			break;
	}
	
	return result;
}

- (BOOL)isDisabled
{
	BOOL result = NO;
	
	switch (self.authorizationStatus)
	{
		case kCLAuthorizationStatusDenied:
		case kCLAuthorizationStatusRestricted:
			result = YES;
			break;

		default:
			result = NO;
	}
	
	return result;
}

#pragma mark - 

- (void)showDisableAlert
{
	NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	NSString *msgTemplate = NSLocalizedString(@"%@ need access to your location. Please turn on Location Services in your device settings.", nil);
	NSString *msg = [NSString stringWithFormat:msgTemplate, appName];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location Services is disabled", nil)
														message:msg
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"No thanks", nil)
											  otherButtonTitles:NSLocalizedString(@"Go to settings", nil), nil];
	[alertView promise].then(^(NSNumber *buttonIndex) {
		if (buttonIndex.intValue == 1) {
			NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
			[[UIApplication sharedApplication] openURL:url];
		}
	});
}

@end
