//
//  NSMutableDictionary+CPUtils.m
//  CityParking
//
//  Created by Igor Zubko on 17.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "NSMutableDictionary+CPUtils.h"

@implementation NSMutableDictionary (CPUtils)

- (void)cp_addObject:(id)object forKey:(id<NSCopying>)key
{
	if (object != nil && key != nil) {
		[self setObject:object forKey:key];
	}
}

@end
