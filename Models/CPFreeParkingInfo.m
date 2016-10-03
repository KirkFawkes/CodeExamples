//
//  CPFreeParkingInfo.m
//  CityParking
//
//  Created by Igor Zubko on 05.12.15.
//  Copyright © 2015 Fastforward. All rights reserved.
//

#import "CPFreeParkingInfo.h"
#import "NSArray+CPUtils.h"
#import <MapKit/MKGeometry.h>

@implementation CPFreeParkingInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
	NSDictionary *properties = @{
		@"lineCoordinates": @"coordinates",
	};
	
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:properties];
}

+ (NSValueTransformer *)lineCoordinatesJSONTransformer
{
	return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray<NSDictionary *> *coordinates, BOOL *success, NSError **error) {
		NSArray<NSValue *> *result = [coordinates cp_map:^NSValue *(NSDictionary *item) {
			DASSERT([item isKindOfClass:[NSDictionary class]]);
			CLLocationDegrees latitude = [item[@"latitude"] doubleValue];
			CLLocationDegrees longitude = [item[@"longitude"] doubleValue];
			return [NSValue valueWithMKCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
		}];
		
		return result;
	} reverseBlock:^id(NSArray<NSValue *> *coordinates, BOOL *success, NSError **error) {
		NSArray<NSDictionary *> *result = [coordinates cp_map:^NSDictionary *(NSValue *item) {
			CLLocationCoordinate2D location = [item MKCoordinateValue];
			return @{@"latitude": @(location.latitude), @"longitude": @(location.longitude)};
		}];
		
		return result;
	}];
}

@end
