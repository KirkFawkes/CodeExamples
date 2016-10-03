//
//  CPUserService.m
//  CityParking
//
//  Created by Igor Zubko on 17.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPUserService.h"
// Services
#import "CPNetworkService.h"
#import "CPConfigService.h"
#import "CPAnalitics.h"
// Models
#import "CPPaymentsCardModel.h"
#import "CPPaymentsBankModel.h"
// Other
#import <Stripe/Stripe.h>
#import <NSDate+DateTools.h>
#import "constants.h"
#import "CPErrorCodes.h"
// categories
#import "NSDictionary+CPUtils.h"
#import "STPAPIClient+Promises.h"

NSString * const kCPUserServiceAuthorizationChanged = @"com.cityparking.notificaiton.userchanged";

@implementation CPUserService
@synthesize currentUser = _currentUser;

- (instancetype)init
{
	if (self = [super init])
	{
		[Stripe setDefaultPublishableKey:CPConfigStripePublishableKey];
	}
	
	return self;
}

#pragma mark - Properties

- (CPCurrentUserInfoModel *)currentUser
{
	if (self->_currentUser == nil) {
		DASSERTWARNING(self.configService != nil);
		self->_currentUser = self.configService.currentUser;
	}
	
	return self->_currentUser;
}

- (void)setCurrentUser:(CPCurrentUserInfoModel *)currentUser
{
	self->_currentUser = currentUser;
	self.configService.currentUser = currentUser;
	
	[self.analiticsService setUserId:currentUser.objectId];
}

#pragma mark - Payments

- (void)addBankAccount:(STPBankAccountParams *)bankParams birthday:(NSDate *)birthday withSuccessBlock:(CPServiceSuccessBlock)successBlock andErrorBlock:(CPServiceErrorBlock)errorBlock
{
	DASSERT(bankParams != nil);
	DASSERT(birthday != nil);
	DASSERT([self.currentUser isAuthorized]);
	
	[[STPAPIClient sharedClient] createTokenWithBankAccount:bankParams completion:^(STPToken * _Nullable token, NSError * _Nullable error) {
		if (error) {
			CPSafeCallBlock(errorBlock, error);
			return;
		} else if (token.tokenId.length == 0) {
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Something wrong with stripe", nil)};
			CPSafeCallBlock(errorBlock, [NSError errorWithDomain:@"com.cityparking.stripe" code:23 userInfo:userInfo]);
			return;
		}
		
		NSString *path = @"/user/external_account";
		NSDictionary *params = @{
			@"token_id": token.tokenId,
			@"dob": [birthday formattedDateWithFormat:kConfigDefultDateFormat]
		};
	
		[self.networkService sendJSONRequest:path withMethod:CPNetworkMethodPUT params:params callback:^(id object, NSURLResponse *response, NSError *error) {
			if (error) {
				CPSafeCallBlock(errorBlock, error);
				return;
			}

			CPPaymentsBankModel *bank = [CPPaymentsBankModel objectFromDictionary:@{@"currency": bankParams.currency, @"last": bankParams.last4} error:nil];
			CPSafeCallBlock(successBlock, bank); // Fix this
		}];
	}];
}	

- (void)requestPaymentsListSuccessBlock:(CPServiceSuccessBlock)successBlock andErrorBlock:(CPServiceErrorBlock)errorBlock
{
	[self.networkService sendJSONRequest:@"/user" withMethod:CPNetworkMethodGET params:nil callback:^(NSDictionary *result, NSURLResponse *response, NSError *error) {
		if (error != nil) {
			CPSafeCallBlock(errorBlock, error);
			return;
		}
		
		NSDictionary *p = [result cp_filterEmpty];
		
		NSString *brand = p[@"cardBrand"];
		NSString *last = p[@"cardLast4"];
		NSString *cardId = [@(arc4random()) description];
		
		NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
		[dictionary cp_addObject:brand forKey:@"brand"];
		[dictionary cp_addObject:last forKey:@"last"];
		[dictionary cp_addObject:cardId forKey:@"id"];
		
		if (dictionary.count > 1) {
			CPPaymentsCardModel *card = [CPPaymentsCardModel objectFromDictionary:dictionary error:nil];
			CPSafeCallBlock(successBlock, @[card]);
		} else {
			CPSafeCallBlock(successBlock, @[]);
		}
	}];
}

- (PMKPromise *)addBankAccount:(STPBankAccountParams *)bankParams birthday:(NSDate *)birthday
{
	return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
		[self addBankAccount:bankParams birthday:birthday withSuccessBlock:^(id result) {
			fulfill(result);
		} andErrorBlock:^(NSError *error) {
			reject(error);
		}];
	}];
}

/////////////////////////////
#pragma mark -
#pragma mark - Authorization

- (PMKPromise *)authorizeUser:(CPAuthUserModel *)userInfo
{
	DASSERT(userInfo != nil);
	
	NSString * const method = CPNetworkMethodPOST;
	NSString * const path = @"/login";
	
	NSMutableDictionary * const params = [NSMutableDictionary dictionary];
	[params cp_addObject:userInfo.email forKey:@"email"];
	[params cp_addObject:userInfo.password forKey:@"password"];
	
	return [self.networkService sendJSONRequest:path withMethod:method params:params].then(^id (NSDictionary *object) {
		NSString *token = object[@"token"];
		
		if (!token) {
			return CPErrorMake(kCPErrorCodeServerDoesNotSendAuthToken, NSLocalizedString(@"Server don't send authorization token", nil));
		}
		
		CPCurrentUserInfoModel *currentUser = [[CPCurrentUserInfoModel alloc] initWithToken:token];
		currentUser.email = userInfo.email;
		
		self.currentUser = currentUser;
		
		return [self requestUserInformation];
	});
}

- (PMKPromise *)authorizeWithFacebook:(NSString *)facebookToken
{
	DASSERT(facebookToken.length > 0);
	
	NSString * const method = CPNetworkMethodGET;
	NSString * const path = [NSString stringWithFormat:@"/login/facebook/%@", facebookToken];
	
	return [self.networkService sendJSONRequest:path withMethod:method params:nil].then(^id (NSDictionary *object) {
		NSString *token = object[@"token"];
		
		if (!token) {
			return CPErrorMake(kCPErrorCodeServerDoesNotSendAuthToken, NSLocalizedString(@"Server don't send authorization token", nil));
		}
		
		CPCurrentUserInfoModel *currentUser = [[CPCurrentUserInfoModel alloc] initWithToken:token];
		self.currentUser = currentUser;
		
		return [self requestUserInformation];
	});
}

- (PMKPromise *)registerUser:(CPRegisterUserInfoModel *)userInfo
{
	DASSERT(userInfo != nil);
	
	NSString * const method = CPNetworkMethodPUT;
	NSString * const path = @"/user";
	
	NSMutableDictionary * const params = [NSMutableDictionary dictionary];
	[params cp_addObject:userInfo.email forKey:@"email"];
	[params cp_addObject:userInfo.firstName forKey:@"firstName"];
	[params cp_addObject:userInfo.lastName forKey:@"lastName"];
	[params cp_addObject:userInfo.phone forKey:@"phone"];
	[params cp_addObject:userInfo.password forKey:@"password"];
	
	return [self.networkService sendJSONRequest:path withMethod:method params:@{@"user": params}];
}

- (PMKPromise *)resetPasswordForEmail:(NSString *)email
{
	DASSERT(email.length > 0);
	
	NSString * const method = CPNetworkMethodGET;
	NSString * const path = [NSString stringWithFormat:@"/user/forgetpassword/%@", email];
	
	return [self.networkService sendJSONRequest:path withMethod:method params:nil];
}

- (PMKPromise *)logout
{
	if (![self.currentUser isAuthorized]) {
		NSError *error = CPErrorMake(kCPErrorCodeUserNotAuthorized, NSLocalizedString(@"User not authorized", nil));
		return [PMKPromise promiseWithValue:error];
	}
	
	NSString * const method = CPNetworkMethodGET;
	NSString * const path = @"/logout";
	
	return [self.networkService sendJSONRequest:path withMethod:method params:nil].then(^{
		self.currentUser = nil;
	});
}

#pragma mark - User

- (PMKPromise *)requestUserInformation
{
	if (![self.currentUser isAuthorized]) {
		NSError *error = CPErrorMake(kCPErrorCodeUserNotAuthorized, NSLocalizedString(@"User not authorized", nil));
		return [PMKPromise promiseWithValue:error];
	}

	NSString * const method = CPNetworkMethodGET;
	NSString * const path = @"/user";

	return [self.networkService sendJSONRequest:path withMethod:method params:nil].then(^(NSDictionary *p) {
		self.currentUser = [self.currentUser updateWithDictionary:p];
		return self.currentUser;
	});
}

- (PMKPromise *)requestUserInformationById:(CPObjectModelId)userId
{
	DASSERT(userId != nil);
	
	NSString * const method = CPNetworkMethodGET;
	NSString * const path = [NSString stringWithFormat:@"/user/info/%@", userId];
	
	return [self.networkService sendJSONRequest:path withMethod:method params:nil].thenInBackground(^(NSDictionary *object) {
		CPUserInfoModel *userInfo = [CPUserInfoModel new];
		userInfo.objectId = object[@"id"];
		userInfo.email = object[@"email"];
		userInfo.firstName = object[@"firstName"];
		userInfo.lastName = object[@"lastName"];
		userInfo.phone = object[@"phone"];
		
		return userInfo;
	});
}

- (PMKPromise *)updateUserInformation:(NSDictionary *)userInformation
{
	DASSERT(userInformation != nil);
	
	NSString * const method = CPNetworkMethodPOST;
	NSString * const path = @"/user";
	
	NSDictionary * const params = @{@"user": userInformation};
	
	return [self.networkService sendJSONRequest:path withMethod:method params:params].then(^{
		return [self requestUserInformation];
	});
}

- (PMKPromise *)changePassword:(NSString *)oldPassword toNewPassword:(NSString *)newPassword
{
	DASSERT(oldPassword.length > 0);
	DASSERT(newPassword.length > 0);
	
	NSString * const method = CPNetworkMethodPUT;
	NSString * const path = @"/user/changepassword";
	NSDictionary * const params = @{@"old_password": oldPassword, @"new_password": newPassword};
	
	return [self.networkService sendJSONRequest:path withMethod:method params:params];
}

#pragma mark - Phone

- (PMKPromise *)confirmPhoneNumberWithCode:(NSString *)code phone:(NSString *)phone
{
	DASSERT(code.length > 0);
	DASSERT(phone.length > 0);
	
	NSString * const method = CPNetworkMethodGET;
	NSString * const path = [NSString stringWithFormat:@"/user/confirmphone/%@/%@", code, phone];
	
	return [self.networkService sendJSONRequest:path withMethod:method params:nil].then(^id (NSDictionary *object) {
		NSString *token = object[@"token"];
		
		if (!token) {
			return CPErrorMake(kCPErrorCodeServerDoesNotSendAuthToken, NSLocalizedString(@"Server don't send authorization token", nil));
		}
		
		CPCurrentUserInfoModel *currentUser = [[CPCurrentUserInfoModel alloc] initWithToken:token];
		self.currentUser = currentUser;
		
		return [self requestUserInformation];
	});
}

- (PMKPromise *)resendConfirmationCode:(NSString *)phone
{
	DASSERT(phone.length > 0);
	
	NSString * const method = CPNetworkMethodGET;
	NSString * const path = [NSString stringWithFormat:@"/user/resendcode/%@", phone];
	
	return [self.networkService sendJSONRequest:path withMethod:method params:nil];
}

#pragma mark - Credit cards

- (PMKPromise *)addCreditCard:(STPCardParams *)cardParams
{
	DASSERT(cardParams != nil);
	
	if (![self.currentUser isAuthorized]) {
		NSError *error = CPErrorMake(kCPErrorCodeUserNotAuthorized, NSLocalizedString(@"User not authorized", nil));
		return [PMKPromise promiseWithValue:error];
	}

	return [[STPAPIClient sharedClient] cp_createTokenWithCard:cardParams].thenInBackground(^id (STPToken *token) {
		if (token.tokenId.length == 0) {
			return CPErrorMake(kCPErrorCodeStripeTokenEmpty, NSLocalizedString(@"Stripe card token is empty", nil));
		}
		
		NSString * const method = CPNetworkMethodPUT;
		NSString * const path = @"/user/stripecustomer";
		NSDictionary * const params = @{ @"token_id": token.tokenId };
		
		return [self.networkService sendJSONRequest:path withMethod:method params:params].then(^{
			self.currentUser = [self.currentUser updateWithCreditCard:token.card];
		});
	});
}

- (PMKPromise *)removeCreditCard:(CPObjectModelId)cardId
{
	DASSERT(cardId != nil);
	
	NSString * const method = CPNetworkMethodDELETE;
	NSString * const path = @"/user/stripecustomer";
	
	return [self.networkService sendJSONRequest:path withMethod:method params:nil];
}

@end
