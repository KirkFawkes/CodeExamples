//
//  NSDate+CPUtils.h
//  CityParking
//
//  Created by Igor Zubko on 21.12.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CPUtils)

- (NSDate *)cp_roundToNextMinutes:(NSUInteger)minutes;

@end
