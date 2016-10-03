//
//  NSDictionary+CPUtils.m
//  CityParking
//
//  Created by Igor Zubko on 23.12.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "NSDictionary+CPUtils.h"

@implementation NSDictionary (CPUtils)

- (NSDictionary *)cp_map:(id (^)(id key, id item))mapBlock
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:self.count];
	
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		id result = mapBlock(key, obj);
		
		if (result != nil && result != [NSNull null]) {
			[dictionary setObject:result forKey:key];
		}
	}];
	
	return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (NSDictionary *)cp_filter:(BOOL (^)(id key, id item))filterBlock
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:self.count];
	
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if (filterBlock(key, obj)) {
			[dictionary setObject:obj forKey:key];
		}
	}];
	
	return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (NSDictionary *)cp_removeKeys:(NSArray *)keysToRemove
{
	if (keysToRemove.count == 0) {
		return self;
	}
	
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self];
	[keysToRemove enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[dictionary removeObjectForKey:obj];
	}];
	
	return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (NSDictionary *)cp_filterEmpty
{
	return [self cp_filter:^BOOL(id key, id item) {
		return ![item isKindOfClass:[NSNull class]] && !([item isKindOfClass:[NSString class]] && [(NSString *)item length] == 0);
	}];
}

@end
