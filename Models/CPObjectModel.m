//
//  CPObjectModel.m
//  CityParking
//
//  Created by Igor Zubko on 20.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPObjectModel.h"

@implementation CPObjectModel

+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary error:(NSError **)error
{
	return [MTLJSONAdapter modelOfClass:self fromJSONDictionary:dictionary error:error];
}

+ (NSArray *)objectsFromArray:(NSArray<NSDictionary *> *)array error:(NSError **)error
{
	return [MTLJSONAdapter modelsOfClass:self fromJSONArray:array error:error];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
	return @{
		@"objectId": @"id",
    };
}

+ (NSValueTransformer *)objectJSONTransformer
{
	return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError **error) {
		if ([value isKindOfClass:[NSString class]]) {
			return value;
		}
		
		return [value description];
	} reverseBlock:^id(id value, BOOL *success, NSError **error) {
		return value;
	}];
}

@end
