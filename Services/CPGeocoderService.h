//
//  CPParkingService.h
//  CityParking
//
//  Created by Igor Zubko on 10.11.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLPlacemark.h>
#import "CPNetworkService.h"
// other
#import <PromiseKit/PromiseKit.h>

@interface CPGeocoderItem : NSObject
@property (nonatomic, readonly) NSString *address;
@property (nonatomic, readonly) CLLocation *location;

- (instancetype)initWithPlacemark:(CLPlacemark *)placemark;

@end

typedef void(^CPGeocoderServiceDoneBlock)(NSArray *result, NSError *error);

@interface CPGeocoderService : NSObject

- (void)query:(NSString *)query doneBlock:(CPGeocoderServiceDoneBlock)doneBlock;
- (void)queryCancel;

- (void)geocodeLocation:(CLLocation *)location withSuccessBlock:(CPServiceSuccessBlock)successBlock andErrorBlock:(CPServiceErrorBlock)errorBlock;

#pragma mark - Search

- (PMKPromise *)suggestCompletionFor:(NSString *)query;

@end
