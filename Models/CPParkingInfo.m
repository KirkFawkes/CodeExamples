//
//  CPParkingInfo.m
//  CityParking
//
//  Created by Igor Zubko on 06.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPParkingInfo.h"

/**********************************************************************************/

BOOL ExtractBolean(id value)
{
	if ([value isKindOfClass:[NSString class]])
	{
		NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
		f.numberStyle = NSNumberFormatterDecimalStyle;
		NSNumber *num = [f numberFromString:value];
		if (num != nil) {
			return num.boolValue;
		}
		
		return [[(NSString *)value lowercaseString] isEqualToString:@"true"];
	}
	
	if ([value isKindOfClass:[NSNumber class]]) {
		return [(NSNumber *)value boolValue];
	}
	
	[NSException raise:@"Unknown boolean format" format:@"<%@> %@", [value class], value];
	return NO;
}

NSNumber *ExtractNumber(id value)
{
	if ([value isKindOfClass:[NSNumber class]]) {
		return value;
	}
	
	if ([value isKindOfClass:[NSString class]])
	{
		return @([(NSString *)value floatValue]);
	}
	
	return nil;
}


/**********************************************************************************/

@implementation CPParkingInfo

- (instancetype)init
{
	if (self = [super init])
	{
		self->_status = CPParkingInfoAvailableStatusAvailable;
	}
	
	return self;
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
	NSDictionary *properties = @{
//		@"title": @"name",				// *string*
	};
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:properties];
}

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary
{
	if (JSONDictionary[@"price"] != nil && JSONDictionary[@"location"] != nil) {
		return CPPaidParkingInfo.class;
	}

	if (JSONDictionary[@"coordinates"] != nil) {
		return CPFreeParkingInfo.class;
	}

	return self;
}

@end
