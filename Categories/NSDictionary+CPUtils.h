//
//  NSDictionary+CPUtils.h
//  CityParking
//
//  Created by Igor Zubko on 23.12.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary<__covariant KeyType, __covariant ObjectType> (CPUtils)
- (NSDictionary<KeyType, ObjectType> *)cp_map:(id (^)(KeyType key, ObjectType item))mapBlock;
- (NSDictionary<KeyType, ObjectType> *)cp_filter:(BOOL (^)(KeyType key, ObjectType item))filterBlock;

- (NSDictionary<KeyType, ObjectType> *)cp_removeKeys:(NSArray *)keysToRemove;

- (NSDictionary<KeyType, ObjectType> *)cp_filterEmpty;
@end
