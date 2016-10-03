//
//  NSData+NSInputStream.h
//  CityParking
//
//  Created by Igor Zubko on 17.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (NSInputStream)

+ (NSData *)cp_dataWithContentsOfStream:(NSInputStream *)input initialCapacity:(NSUInteger)capacity error:(NSError **)error;

- (NSString *)toString;

- (NSString *)togHexSting;

@end
