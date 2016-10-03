//
//  NSMutableDictionary+CPUtils.h
//  CityParking
//
//  Created by Igor Zubko on 17.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (CPUtils)

- (void)cp_addObject:(id)object forKey:(id<NSCopying>)key;

@end
