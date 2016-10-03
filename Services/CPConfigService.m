//
//  CPConfigService.m
//  CityParking
//
//  Created by Igor Zubko on 17.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPConfigService.h"
//
#import "CPUserInfoModel.h"
// Categories
#import "NSMutableDictionary+CPUtils.h"
// Opther
#import <SSKeychain/SSKeychain.h>
#import <SSKeychain/SSKeychainQuery.h>

static NSString * const kCPConfigServiceCurrentUserKey = @"UserID";

@implementation CPConfigService

#pragma mark - Helpers

- (NSString *)keychainServiceName
{
	NSURL *url = [NSURL URLWithString:CPConfigServerBaseUrl];
	DASSERT(url.host.length > 0);
	return [url.host stringByReplacingOccurrencesOfString:@"." withString:@"_"];
}

#pragma mark - CPCurrentUserInfoModel

- (void)setCurrentUser:(CPCurrentUserInfoModel *)currentUser
{
	NSUserDefaults *userDefaaults = [NSUserDefaults standardUserDefaults];
	
	if (currentUser == nil)
	{
		[userDefaaults removeObjectForKey:kCPConfigServiceCurrentUserKey];
	} else {
		[userDefaaults setObject:currentUser.objectId forKey:kCPConfigServiceCurrentUserKey];
		
		if (currentUser.objectId)
		{
			NSError *error = nil;
			[SSKeychain setPassword:currentUser.accessToken forService:[self keychainServiceName] account:[currentUser.objectId description] error:&error];
		
			if (error) {
				DLOG(@"Keychain error: %@", error);
			}
		}
	}
	
	[userDefaaults synchronize];
}

- (CPCurrentUserInfoModel *)currentUser
{
	NSUserDefaults *userDefaaults = [NSUserDefaults standardUserDefaults];
	
	id currentUserID = [userDefaaults objectForKey:kCPConfigServiceCurrentUserKey];
	
	if (currentUserID == nil) {
		return nil;
	}
	
	NSError *error = nil;
	id accessToken = [SSKeychain passwordForService:[self keychainServiceName] account:[currentUserID description] error:&error];
	
	if (error != nil) {
		DLOG(@"Keychain error: %@", error.localizedDescription);
		return nil;
	}
	
	if (accessToken == nil) {
		return nil;
	}
	
	CPCurrentUserInfoModel *userInfo = [[CPCurrentUserInfoModel alloc] initWithToken:accessToken];
	[userInfo updateWithDictionary:@{@"id": currentUserID}];
	
	return userInfo;
}

#pragma mark - Custom properties

- (id)objectForKey:(NSString *)key
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)setObject:(id)object forKey:(NSString *)key
{
	NSUserDefaults *userDefaaults = [NSUserDefaults standardUserDefaults];
	if (object) {
		[userDefaaults setObject:object forKey:key];
	} else {
		[userDefaaults removeObjectForKey:key];
	}
	
	[userDefaaults synchronize];
}

- (void)setMapRect:(MKMapRect)rect forKey:(NSString *)key
{
	if (MKMapRectIsNull(rect)) {
		[self setObject:nil forKey:key];
	} else {
		[self setObject:MKStringFromMapRect(rect) forKey:key];
	}
}

- (MKMapRect)mapRectForKey:(NSString *)key
{
	NSString *mapRectString = [self objectForKey:key];
	if (mapRectString) {
		CGRect rect = CGRectFromString(mapRectString);
		
		MKMapRect mapRect;
		mapRect.origin.x = rect.origin.x;
		mapRect.origin.y = rect.origin.y;
		mapRect.size.width = rect.size.width;
		mapRect.size.height = rect.size.height;
		return mapRect;
	}
	
	return MKMapRectNull;
}

@end
