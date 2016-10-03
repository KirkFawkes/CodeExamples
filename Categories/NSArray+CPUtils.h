//
//  NSArray+CPUtils.h
//  CityParking
//
//  Created by Igor Zubko on 17.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<__covariant ObjectType> (CPUtils)

- (NSArray<ObjectType> *)cp_filter:(BOOL (^)(ObjectType item))filterBlock;

- (NSArray *)cp_map:(id (^)(ObjectType item))mapBlock;

- (ObjectType)cp_findFirst:(BOOL (^)(ObjectType item))searchBlock;

- (NSUInteger)cp_count:(BOOL (^)(ObjectType item))countBlock;

- (void)cp_foreach:(void (^)(ObjectType item))block;

@end
