//
//  CPBookingInfoModel.m
//  CityParking
//
//  Created by Igor Zubko on 30.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPBookingInfoModel.h"
#import "CPParkingInfo.h"
#import <DateTools/DateTools.h>

@implementation CPBookingInfoModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
	NSDictionary *properties = @{
		@"startTime": @"bookedFrom",	// *string*
		@"endTime": @"bookedTo",		// *string*
		@"amount": @"amount",			// *float*
		@"parking": @"driveway",		// *dictionary*
	};
	
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:properties];
}

#pragma mark - Value transformers

+ (NSValueTransformer *)startTimeJSONTransformer
{
	return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
		return NSStringToDateFull(value);
	} reverseBlock:^id(id value, BOOL *success, NSError **error) {
		return NSDateToStringFull(value);
	}];
}

+ (NSValueTransformer *)endTimeJSONTransformer
{
	return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
		return NSStringToDateFull(value);
	} reverseBlock:^id(id value, BOOL *success, NSError **error) {
		return NSDateToStringFull(value);
	}];
}

+ (NSValueTransformer *)amountJSONTransformer
{
	return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
		return ExtractNumber(value);
	} reverseBlock:^id(id value, BOOL *success, NSError **error) {
		return [NSString stringWithFormat:@"%@", value];
	}];
}

+ (NSValueTransformer *)parkingJSONTransformer
{
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:CPParkingInfo.class];
}

@end
