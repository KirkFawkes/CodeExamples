//
//  NSArray+CPUtils.m
//  CityParking
//
//  Created by Igor Zubko on 17.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "NSArray+CPUtils.h"

@implementation NSArray (CPUtils)

- (NSArray *)cp_filter:(BOOL (^)(id item))filterBlock
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
	
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (filterBlock(obj)) {
			[array addObject:obj];
		}
	}];
	
	return [NSArray arrayWithArray:array];
}

- (NSArray *)cp_map:(id (^)(id item))mapBlock
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
	
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		id res = mapBlock(obj);
		if (res != nil) {
			[array addObject:mapBlock(obj)];
		}
	}];
	
	return [NSArray arrayWithArray:array];
}

- (id)cp_findFirst:(BOOL (^)(id item))searchBlock
{
	for (id item in self) {
		if (searchBlock(item)) {
			return item;
		}
	}
	
	return nil;
}

- (NSUInteger)cp_count:(BOOL (^)(id item))countBlock
{
	__block NSUInteger count = 0;
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (countBlock(obj)) {
			count++;
		}
	}];
	
	return count;
}

- (void)cp_foreach:(void (^)(id item))block
{
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		block(obj);
	}];
}
@end
