//
//  CPNotificaitonService.m
//  CityParking
//
//  Created by Igor Zubko on 07.12.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPNotificaitonService.h"
// models
#import "CPBookingInfoModel.h"
// categories
#import "NSData+NSInputStream.h"
#import <NSDate+DateTools.h>

#define kConfigAutoRenewTimeInMinutes	60

NSInteger const kErrorCodeUserNotSpecefied		= 55;
NSInteger const kErrorCodeBookingNotSpecefied	= kErrorCodeUserNotSpecefied + 1;
NSInteger const kErrorCodeWrongUser				= kErrorCodeBookingNotSpecefied + 1;

NSString * const kErrorDomain = @"com.cityparking.notification";

NSString * const kPushNotificationActionCategoryBookingExpire  = @"BOOK_EXPIRE";   // expire in 15 minutes
NSString * const kPushNotificationActionCategoryBookingRenew   = @"BOOK_RENEW";    // expire and can be renew automaticaly

NSString * const kPushNotificationActionCategoryBookingExpireActRenew = @"renew";
NSString * const kPushNotificationActionCategoryBookingExpireActInstantRenew = @"instant_renew";

@implementation CPNotificaitonService

- (void)registerForNotifications
{
	UIApplication *application = [UIApplication sharedApplication];
	
	if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
	{ // iOS 8.0+
		UIMutableUserNotificationAction *actionExpiring = [UIMutableUserNotificationAction new];
		[actionExpiring setActivationMode:UIUserNotificationActivationModeForeground];
		[actionExpiring setTitle:NSLocalizedString(@"Renew", nil)];
		[actionExpiring setIdentifier:kPushNotificationActionCategoryBookingExpireActRenew];
		[actionExpiring setAuthenticationRequired:YES];
		[actionExpiring setDestructive:NO];
		
		UIMutableUserNotificationAction *actionRenew = [UIMutableUserNotificationAction new];
		[actionRenew setActivationMode:UIUserNotificationActivationModeBackground];
		[actionRenew setTitle:NSLocalizedString(@"Renew for 1 hour", nil)];
		[actionRenew setIdentifier:kPushNotificationActionCategoryBookingExpireActInstantRenew];
		[actionRenew setAuthenticationRequired:NO];
		[actionRenew setDestructive:NO];
		
		UIMutableUserNotificationCategory *actionCategoryExpire = [UIMutableUserNotificationCategory new];
		[actionCategoryExpire setIdentifier:kPushNotificationActionCategoryBookingExpire];
		[actionCategoryExpire setActions:@[actionExpiring] forContext:UIUserNotificationActionContextDefault];
		[actionCategoryExpire setActions:@[actionExpiring] forContext:UIUserNotificationActionContextMinimal];
		
		UIMutableUserNotificationCategory *actionCategoryRenew = [UIMutableUserNotificationCategory new];
		[actionCategoryRenew setIdentifier:kPushNotificationActionCategoryBookingRenew];
		[actionCategoryRenew setActions:@[actionRenew, actionExpiring] forContext:UIUserNotificationActionContextDefault];
		[actionCategoryRenew setActions:@[actionRenew, actionExpiring] forContext:UIUserNotificationActionContextMinimal];

		NSSet *categories = [NSSet setWithObjects:actionCategoryExpire, actionCategoryRenew, nil];
		
		UIUserNotificationType types = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
		[application registerUserNotificationSettings:settings];
	} else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
		UIRemoteNotificationType types = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
		[application registerForRemoteNotificationTypes:types];
#endif
	}
}

- (void)didRegisterWithDeviceToken:(NSData *)deviceToken
{
	NSString *deviceTokenString = [deviceToken togHexSting];
	
	if (deviceTokenString.length > 0)
	{
		NSString *path = @"/user/notifications/ios";
		NSDictionary *params = @{@"deviceToken": deviceTokenString};
	
		[self.networkService sendJSONRequest:path withMethod:CPNetworkMethodPUT params:params callback:^(NSDictionary *result, NSURLResponse *response, NSError *error) {
			if (error != nil)
			{
				DLOG(@"Push token registration error: %@", error);
				return;
			}
			
			DLOG(@"Registed push token: %@", deviceTokenString);
		}];
	}
}

- (void)didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo
{
	DLOG(@"%@", userInfo);
}

- (void)handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(nonnull NSDictionary *)userInfo completionHandler:(nonnull void (^)())completionHandler
{
	NSString *category = userInfo[@"aps"][@"category"];

	if ([category isEqualToString:kPushNotificationActionCategoryBookingExpire]) {
		// bookig expire soon and need to show renew screen
		
	} else if ([category isEqualToString:kPushNotificationActionCategoryBookingRenew]) {
		// booking expire soon and need to renew it in the background
		
		[self.analiticsService trackButtonAction:@"Renew_for_60_minutes" inScreen:@"NotificationCenter"];
		
		NSNumber *userID = userInfo[@"aps"][@"uid"] ? : userInfo[@"uid"];
		NSNumber *bookingId = userInfo[@"aps"][@"bid"] ? : userInfo[@"bid"];
		[self autorenewBookingByID:bookingId forUserID:userID].then(^{
			DLOG(@"Renew success");
			
		}).catch(^(NSError *error) {
			[self.analiticsService trackError:@"PushNotification" withMessage:@"Renew error" andError:error];
			DLOG(@"Renew error: %@", error);
			
			// TODO: schedule local notificaiton
		}).finally(completionHandler);
		
	}
}

#pragma mark - Helpers

- (PMKPromise *)autorenewBookingByID:(CPObjectModelId)bookingId forUserID:(CPObjectModelId)userId
{
	return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
		// step 1: validate if booking and user specefied
		NSError *result = nil;
		
		if (bookingId == nil) {
			result = [NSError errorWithDomain:kErrorDomain code:kErrorCodeBookingNotSpecefied userInfo:nil];
		} else if (userId == nil) {
			result = [NSError errorWithDomain:kErrorDomain code:kErrorCodeUserNotSpecefied userInfo:nil];
		}
		resolve(resolve);
		
	}].then(^{
		// step 2: get booking information and current user infomation
		PMKPromise *userInfomation = [self.userService requestUserInformation];
		PMKPromise *bookingPromise = [self.parkingService requestBookingById:bookingId];
		
		return [PMKPromise all:@[userInfomation, bookingPromise]];
		
	}).then(^(NSArray *results) {
		// step 3: check if userId equal to current user
		
		CPCurrentUserInfoModel *user = results[0];
		CPBookingInfoModel *booking = results[1];
		
		if (![[user.objectId description] isEqualToString:[userId description]]) {
			return (id)[NSError errorWithDomain:kErrorDomain code:kErrorCodeWrongUser userInfo:nil];
		}
		
		NSDate *endTime = [booking.endTime dateByAddingMinutes:kConfigAutoRenewTimeInMinutes];
		
		return (id)[self.parkingService renewBookingWithId:bookingId to:endTime];
	});
}

@end
