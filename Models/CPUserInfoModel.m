//
//  CPUserInfoModel.m
//  CityParking
//
//  Created by Igor Zubko on 17.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPUserInfoModel.h"
#import <Stripe/Stripe.h>

static inline id UpdatedParam(id param1, id param2) {
	return (param2 != nil && ![param2 isKindOfClass:[NSNull class]]) ? param2 : param1;
}

@implementation CPUserModel
@end

@implementation CPUserInfoModel

- (NSString *)fullName
{
	NSMutableString *result = [NSMutableString string];
	if (self.firstName.length > 0) {
		[result appendString:self.firstName];
	}
	
	if (self.lastName.length > 0) {
		NSString *format = result.length==0 ? @"%@" : @"%@ ";
		[result appendFormat:format, self.lastName];
	}
	
	return [NSString stringWithString:result];
}

@end

#pragma mark -

@implementation CPRegisterUserInfoModel
@end

@implementation CPAuthUserModel
@end

#pragma mark -

@implementation CPCurrentUserInfoModel

- (instancetype)initWithToken:(id)token
{
	if (self = [super init])
	{
		self->_accessToken = token;
	}
	
	return self;
}

- (instancetype)initWithToken:(id)token andCreditCard:(STPCard *)creditCard
{
	if (self = [super init])
	{
		self->_accessToken = token;
		self->_creditCardLast4 = creditCard.last4;
		self->_creditCardBrand = [self cardBrandString:creditCard.brand];
	}
	
	return self;
}

- (instancetype)updateWithDictionary:(NSDictionary *)dictionary
{
	// TODO: Return copy of object
	self->_creditCardLast4 = UpdatedParam(self.creditCardLast4, dictionary[@"cardLast4"]);
	self->_creditCardBrand = UpdatedParam(self.creditCardLast4, dictionary[@"cardBrand"]);
	
	// Quick fix for dumb backend responses
	if (self->_creditCardLast4.length == 0) {
		self->_creditCardLast4 = nil;
	}
	
	if (self->_creditCardBrand.length == 0) {
		self->_creditCardBrand = nil;
	}
	
	self.email = UpdatedParam(self.email, dictionary[@"email"]);
	self.firstName = UpdatedParam(self.firstName, dictionary[@"firstName"]);
	self.lastName = UpdatedParam(self.lastName, dictionary[@"lastName"]);
	
	self.phone = UpdatedParam(self.phone, dictionary[@"phone"]);
	
	self.objectId = UpdatedParam(self.objectId, dictionary[@"id"]);

	return self;
}

- (instancetype)updateWithCreditCard:(STPCard *)creditCard
{
	self->_creditCardLast4 = creditCard.last4;
	self->_creditCardBrand = [self cardBrandString:creditCard.brand];
	
	return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
		self->_accessToken = [aDecoder decodeObjectForKey:@"token"];
		self->_creditCardLast4 = [aDecoder decodeObjectForKey:@"card"];
		self->_creditCardBrand = [aDecoder decodeObjectForKey:@"cardBrand"];
		self.email = [aDecoder decodeObjectForKey:@"email"];
		self.firstName = [aDecoder decodeObjectForKey:@"firstName"];
		self.lastName = [aDecoder decodeObjectForKey:@"lastName"];
		self.phone = [aDecoder decodeObjectForKey:@"phone"];
		self.objectId = [aDecoder decodeObjectForKey:@"id"];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.accessToken forKey:@"token"];
	[aCoder encodeObject:self.creditCardLast4 forKey:@"card"];
	[aCoder encodeObject:self.creditCardBrand forKey:@"cardBrand"];
	[aCoder encodeObject:self.email forKey:@"email"];
	[aCoder encodeObject:self.firstName forKey:@"firstName"];
	[aCoder encodeObject:self.lastName forKey:@"lastName"];
	[aCoder encodeObject:self.phone forKey:@"phone"];
	[aCoder encodeObject:self.objectId forKey:@"id"];
}

#pragma mark - Helpers

- (NSString *)cardBrandString:(STPCardBrand)brand
{
	switch (brand)
	{
		case STPCardBrandAmex:
			return @"American Express";
		case STPCardBrandDinersClub:
			return @"Diners Club";
		case STPCardBrandDiscover:
			return @"Discover";
		case STPCardBrandJCB:
			return @"JCB";
		case STPCardBrandMasterCard:
			return @"MasterCard";
		case STPCardBrandVisa:
			return @"Visa";
		default:
			return nil;
	}
	
//	amex
//	diners
//	discover
//	jcb
//	mastercard
//	visa
}

#pragma mark -

- (BOOL)isAuthorized
{
	return [(NSString *)self.accessToken length] > 0;
}

- (BOOL)isCreditCardAttached
{
	if ([self.creditCardLast4 isKindOfClass:[NSNull class]] || self.creditCardLast4 == nil) {
		return NO;
	}
	
	return (self.creditCardLast4.length > 0);
}

@end